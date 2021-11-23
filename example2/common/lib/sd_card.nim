# Converted for nim language by audin, 2018/12.
#
# -- Title: Library for communicating with SD memory cards
# -- Author: Matthew Schinkel - borntechi.com, copyright (c) 2009, all rights reserved.
# -- Adapted-by:
# -- Compiler: >=2.4q2
# -- Revision: $Revision: 3534 $
# --
# -- This file is part of jallib (http://jallib.googlecode.com)
# -- Released under the ZLIB license (http://www.opensource.org/licenses/zlib-license.html)
# --
# -- Description: this library provides functions for SD memory cards.
# --
# -- Notes: SD card SPI mode is 1,1
# --
# --        This version works with standard capacity sd cards up to 4gb and
# --        high capacity up to 32 gb. Extended Capacity up to 2TB
# --        may be supported later on.
# --
# -- Sources:
# -- SanDisk Secure Digital Card - http://www.cs.ucr.edu/~amitra/sdcard/ProdManualSDCardv1.9.pdf
# -- How to use MMC/SDC - http://forums.parallax.com/forums/attach.aspx?a=32012
# --
#
import conf_sys
import systick,spi

const SD_BYTE_PER_SECTOR  = 512

var sd_byte_count: word = 0
var sd_sector_count: word = 0
var sd_sector_select: dword

# *******************************
#  external referenced functions
# *******************************
# proc sd_init*()
# proc sd_start_read*(address: dword)
# proc sd_data_byte*(): byte {.discardable.}
# proc sd_stop_read*()
# proc sd_read_pulse_byte*(count1: word)


# -- Basic Commands
const
    SD_GO_IDLE_STATE = 0
    SD_SEND_OP_COND = 1
    SD_SEND_IF_COND = 8
#SD_SEND_CSD = 9
#    SD_SEND_CID = 10
    SD_STOP_TRANSMISSION = 12
#SD_SEND_STATUS = 13

# -- Read Commands
const
    SD_SET_BLOCKLEN = 16
#    SD_READ_SINGLE_BLOCK = 17
    SD_READ_MULTIPLE_BLOCK = 18
#[
# -- Write Commands
const
    SD_WRITE_BLOCK = 24
    SD_WRITE_MULTIPLE_BLOCK = 25
    SD_PROGRAM_CSD = 27

# -- Write Protection Commands
const
    SD_SET_WRITE_PROT = 28
    SD_CLR_WRITE_PROT = 29
    SD_SEND_WRITE_PROT = 30

# -- Erase Commands
const
    SD_ERASE_WR_BLK_START = 32
    SD_ERASE_WR_BLK_END = 33
    SD_ERASE = 38
]#
# -- Application Specific Commands
const
    SD_APP_CMD = 55
#    SD_GEN_CMD = 56

# -- Other Commands
const
    SD_READ_OCR = 58
#    SD_CRC_ON_OFF = 59

# -- application specific command, must write command 55 first
const
#    SD_SD_STATUS = 13
#    SD_SEND_NUM_WR_BLOCKS = 22
#    SD_SET_WR_BLK_ERASE_COUNT = 23
    SD_SD_APP_OP_COND = 41
#    SD_SET_CLR_CARD_DETECT = 42
#    SD_SEND_SCR = 51

# -- R1 RESPONCE boolS
const
#    SD_IN_IDLE_STATE = 0
#    SD_ERASE_RESET = 1
    SD_ILLEGAL_COMMAND = 2
#    SD_COM_CRC_ERROR = 3
#    SD_ERASE_SEQUENCE_ERROR = 4
#    SD_ADDRESS_ERROR = 5
#    SD_PARAMETER_ERROR = 6

var sd_error: bool = false
var sd_card_type: uint8 = 0

const
    SD_HIGH_CAPACITY = 0
    SD_STANDARD_CAPACITY = 1

# -- carrier used to access SD-Card (pseudo-var dealing with SPI)
# -- number of sectors variable
# dword sd_number_of_sectors; //-- number of sectors * 512 = sd card size

proc sd_get_number_of_sectors() =
    discard

# --------------------------------------------------------------------------------
# -- send a command to the sd card (commands with 1 response only)
# --------------------------------------------------------------------------------
proc send_command(command: byte; data: dword; response: var byte) =
    var x: byte
    # -- send a valid CRC byte only for set idle command
    # -- right bool must always be 1 (stop bool)
    if command == SD_GO_IDLE_STATE:
        x = 0x95
    elif command == SD_SEND_IF_COND:
        x = 0x87
    else:
        x = 0xFF
    let cmd = command + 64         # -- left bools must be 01 (start bools)
    spi_write(0xFF)                # -- send 8 clock pulses
    spi_write(cmd)                 # -- send the command
    spi_write((data shr 24).byte)  # -- send command parameters
    spi_write((data shr 16).byte)  # -- send command parameters
    spi_write((data shr 8).byte)   # -- send command parameters
    spi_write((data).byte)         # -- send command parameters
    # -- CRC data byte, crc disabled in this lib, but required for SD_GO_IDLE_STATE & SD_SEND_IF_COND commands.
    spi_write(x) # -- Get a responce from the card after each command
    const RETRY = 10
    var i = 0
    while i < RETRY:
        response = spi_read()
        if (response and 0x80)==0:
            break
        inc(i)
    when SD_CARD_INFO:
        if i >= RETRY:
            xprintf("\n Fail Command [0x%02X] in send_command", cmd.int)

# --------------------------------------------------------------------------------
# -- check if the sd card is ready after last command.
# --------------------------------------------------------------------------------
proc sd_ready(){.used.} =
    var response: byte = 1
    while response != 0: #    -- wait till last command has been completed
        # ;start sdcard initialize
        send_command(SD_SEND_OP_COND, 1, response) #  CMD1

# --------------------------------------------------------------------------------
# -- initalize the sd card in SPI data transfer mode.
# --------------------------------------------------------------------------------
proc sd_init*(): bool{.inline,discardable.} = # false: fail
    result = false
    when SD_CARD_INFO:
        xprintf("\n[sd_card.nim] Start SD card init")
    var response: byte = 0
    #            -- shows if sd card init is ok
    sdSpiEnable()
    sdLowSpeed()
    # pin_sdo = 0;
    # pin_sdi = 0;
    # pin_sck = 0;
    # -- steps to set sd card to use SPI
    wait_ms8bit(2) #            -- delay
    sd_chip_select(1) #     -- chip select high
    for _ in 1..10:
        spi_write(0xFF) #     -- send clock pulses (0xFF 10 times)
    # ;-- try to contact the sd card
    var count1 = 0
    while response == 0: #  -- try 100 times
        wait_ms8bit(2)         #  -- delay 1ms
        sd_chip_select(0)  #  -- enable the sd card
        wait_ms8bit(2)         # -- delay 255us
        #  -- command 0, Resets card to idle state, get a response
        send_command(SD_GO_IDLE_STATE, 0, response) #  CMD0
        sd_chip_select(1) #   -- disable the sd card
        count1 = count1 + 1 #  -- increment count
        if count1 == 100:
            sd_error = true
            when SD_CARD_INFO:
                xprintf("\n--- Error SD card initialize ! : CMD0")
            return
    # -- send SD_SEND_IF_COND command
    sd_chip_select(0) #  -- enable the sd card
    send_command(SD_SEND_IF_COND, 0x000001AA, response) # CMD8
    if  (response and (1 shl SD_ILLEGAL_COMMAND)) != 0:
        # -- SD CARD SPEC 1
        when SD_CARD_INFO:
            xprintf("\n--- OK!   SDv1 : STANDARD CAPACITY  :CMD8");
        sd_card_type = SD_STANDARD_CAPACITY
        sd_chip_select(0) #   -- enable the sd card
        # sd_ready();//       -- CMD1 wait till sd card is ready
        sd_chip_select(1) #   -- disable the sd card
        sd_get_number_of_sectors()
        return true
    else:
        # -- SD CARD SPEC 2
        when SD_CARD_INFO:
            xprintf("\n--- Found: SDv2 !")
        # ; read OCR 4 byte
        for i in 0..<4:
            response = spi_read() # i=2: 0x01, i=3: 0xAA
        sd_chip_select(1) #     -- disable the sd card
        if response == 0xAA:
            sd_chip_select(0) #   -- enable the sd card
            # -- check if it has completed init
            while true:
                # ; send ACMD41
                send_command(SD_APP_CMD, 0, response)
                send_command(SD_SD_APP_OP_COND, 0x40000000.dword, response)
                if response == 0:
                    break
            when SD_CARD_INFO:
                xprintf("\n--- --- ACMD41 OK")
            # print_string(serial_data, "\nACMD41 OK\n")
            # -- read OCR here
            send_command(SD_READ_OCR, 0, response) #  CMD58
            if (spi_read() and 0x40) != 0: #  ; ocr[0]
                sd_card_type = SD_HIGH_CAPACITY # and BLOCK mode
                when SD_CARD_INFO:
                    xprintf("\n--- --- --- Found: SDHC Block Mode : CMD58")
                # ;print_string(serial_data, "HIGH CAPACITY: Block mode\r\n")
            else:
                #  -- sd card spec 2 standard capacity??
                sd_card_type = SD_STANDARD_CAPACITY
                # and none BLOCK mode
                when SD_CARD_INFO:
                    xprintf("\n--- --- --- Found: SDSC None Block Mode : CMD58")
                # ;print_string(serial_data, "STANDARD CAPACITY: Non Block mode\r\n")
            response = spi_read() # ocr[1]
            response = spi_read() # ocr[2]
            response = spi_read() # ocr[3]
            # -- set block size to 512
            send_command(SD_SET_BLOCKLEN, 512, response)
            #sd_ready()
            sd_chip_select(1) #   -- disable the sd card
            when SD_CARD_INFO:
                xprintf("\n[Finished!]: OK!  SD card init")
        else:
            # ;print_string(serial_data, "\nFail: ACMD41 command\n")
            sd_error = true
            sd_chip_select(1) #   -- disable the sd card
            sd_get_number_of_sectors()
            when SD_CARD_INFO:
                    xprintf("\nOCR read error !")
            return
    sd_get_number_of_sectors()
    sdHiSpeed()
    return true

# --------------------------------------------------------------------------------
# -- set the sd card to idle state
# --------------------------------------------------------------------------------
proc sd_set_idle() =
    var response: byte = 0
    sd_chip_select(0) #   -- enable the sd card
    for i in 1..4:
        send_command(SD_STOP_TRANSMISSION, 0, response) #  -- stop current transmission
    sd_chip_select(1)
    #   -- disable the sd card

# --------------------------------------------------------------------------------
# -- tell sd card you will be reading data from a specified sector
# -- do not interupt read process by switching to another spi component
# --------------------------------------------------------------------------------
proc sd_start_read*(address: dword) =
    var
        response: byte
    sd_sector_select = address
    # -- put spi into mode
    sd_chip_select(0) #   -- enable the sd card
    var xaddress = address
    if sd_card_type == SD_STANDARD_CAPACITY:
        xaddress = address * SD_BYTE_PER_SECTOR.dword
        #  -- make sd card sector addressable, sd cards are normally byte addressable.
    send_command(SD_READ_MULTIPLE_BLOCK, xaddress, response)
    # CMD18
    sd_byte_count = 0
    sd_sector_count = 0
    #      -- reset count
    # wait_idle();

# --------------------------------------------------------------------------------
# -- read 1 bytes from the sd card (pseudo )
# --------------------------------------------------------------------------------
proc sd_data_byte*(): byte {.discardable.} =
    var
        x: byte
        data_byte: byte
    if sd_byte_count == 0: #    -- beginning of sector read
        while spi_read() != 0xFE:
            discard #       -- wait till data is ready to read
    data_byte = spi_read() #                 -- get data byte
    sd_byte_count = sd_byte_count + 1 #      -- increment byte_count
    if sd_byte_count == SD_BYTE_PER_SECTOR: #           -- end of sector read
        sd_byte_count = 0
        sd_sector_count = sd_sector_count + 1 #  -- increment sector number
        x = spi_read() #                      -- get junk crc data, crc is disabled
        x = spi_read() #                      -- get junk crc data, crc is disabled
    return data_byte

# --------------------------------------------------------------------------------
# -- tell sd card you are finished reading
# -- needed to be the same as other mass media libs
# --------------------------------------------------------------------------------
proc sd_stop_read*() =
    sd_set_idle()
    sd_chip_select(1)
    #   -- disable the sd card

# --------------------------------------------------------------------------------
# -- send a read pulse to the sd card, go 1 bytes forward in current sector.
# --------------------------------------------------------------------------------
proc sd_read_pulse_byte*(count1: word) =
    var x: byte
    var i: word
    i = 0
    while i < count1: #            -- loop specified number of times
        x = sd_data_byte() #        -- do a data read and ignore the incomming data
        inc(i)

