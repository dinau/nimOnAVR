# Converted for nim language by audin, 2018/12.
# This file is under MIT License. Refer to "License.txt"
#
import conf_sys
import sd_card

proc xputs(formatstr: cstring)  {.header: "xprintf.h", importc: "xputs",used.}
proc xputc(formatstr: cchar)    {.header: "xprintf.h", importc: "xputc",used.}

# for debug message
const MBR_INFO        = true
const BPB_SEC_INFO    = true
const FAT32_INFO      = true
const FAT_INIT_INFO   = true
const FILE_ENTRY_INFO = true

# *******************************************
#  definition of global variables
# *******************************************
var gdwTargetFileSector*:dword

# *******************************************
#  definition of file local variables
# *******************************************
var lgbDirEntryBuff{.noinit}: array[32, byte]
var lgbBPB_SecPerClus: byte
var lgdwBPB_FileSize:  dword
var lgwBPB_BytesPerSec:word
var lgwBPB_RootEntCnt: word
# --
var lgdwRootdir_sector: dword
var lgwSize_of_root:   word
var lgfFat32: sbit

# *******************************
#  external referenced functions
# *******************************
#proc FAT_init*()
proc readDirEntry*(wDestDirEntryIndex: word)
proc searchNextFile*()
proc getBPB_FileSize*():dword{.inline.} =
    lgdwBPB_FileSize

# *****************
#  FAT_init
# *****************
#
# ; Refer to ChaN's FAT info page,
# ; http://elm-chan.org/docs/fat.html#bpb
# ; Thank you, ChaN san.
#
proc FAT_init*(){.inline.} =
    var bpbBuff{.noinit.}: array[32, byte]
    var dwBPB_SecPerFats32: dword
    var wBPB_RsvdSecCnt: word
    var dwBPB_HiddSec: dword
    var dwBPB_Sector: dword
    when HAVE_FAT32:
        var bBPB_NumFATs: byte
    else:
        const bBPB_NumFATs = 2

    sd_start_read(0) # -- read MBR sector
    when MBR_INFO: # display MBR sector
        xprintf("\n[fat_lib.nim/FAT_init()] Start MBR/FAT read")
        xprintf("\nMBR is:")
        for i in 0..<512:
            if (i mod 16) == 0:
                xprintf("\n %04X:", i)
            xprintf("%02X ", sd_data_byte())
        sd_stop_read()
        sd_start_read(0) # reset address
    sd_read_pulse_byte(454) #        -- go to partition info
    # -- get BPB info sector number 0x1C6
    for bi in 0..<4:
        bpbBuff[bi] = sd_data_byte() #  -- read BPB sector to bpbBuff[]
    dwBPB_Sector  =  cast[ptr dword](bpbBuff[0].addr)[]
    sd_stop_read()
    sd_start_read(dwBPB_Sector) #-- go to BPB info sector
    when BPB_SEC_INFO:
        xprintf("\nBPB_Sector[0x01C6] = 0x%04X [th sector]",dwBPB_Sector);
        xprintf("\nBPB_Info is:");
        xprintf("\n ");
    for bi in 0..<32:
        bpbBuff[bi] = sd_data_byte() #  -- read BPB info to bpbBuff[]
        when BPB_SEC_INFO:
            xprintf("%02X ",bpbBuff[bi]);
            #while true: discard
    # ; register BPB info to each variable
    lgwBPB_BytesPerSec  =  cast[ptr word](bpbBuff[11].addr)[]

    lgbBPB_SecPerClus=  bpbBuff[13]
    wBPB_RsvdSecCnt  =  cast[ptr word](bpbBuff[14].addr)[]
    when HAVE_FAT32:
        bBPB_NumFATs    = bpbBuff[16]
    lgwBPB_RootEntCnt   = cast[ptr word](bpbBuff[17].addr)[]
    dwBPB_SecPerFats32  = cast[ptr word](bpbBuff[22].addr)[].dword # for FAT16
    dwBPB_HiddSec       = cast[ptr dword](bpbBuff[28].addr)[]
    when HAVE_FAT32:
        if (dwBPB_SecPerFats32 and 0x0000FFFF.dword) == 0:
            # ----- enable FAT32 mode
            when FAT32_INFO:
                xprintf("\n[FAT32] formatted card")
            lgfFat32 = true
            for _  in 0..<4: discard sd_data_byte() #  dummy read
            for bi in 0..<4: bpbBuff[bi] = sd_data_byte()
            dwBPB_SecPerFats32 = cast[ptr dword](bpbBuff[0].addr)[]
    # ; /* Root DIR start sector  : (absolute sector) */
    lgdwRootdir_sector = (dwBPB_SecPerFats32 * bBPB_NumFATs) + wBPB_RsvdSecCnt + dwBPB_HiddSec
    lgwSize_of_root = lgwBPB_RootEntCnt * 32
    sd_stop_read()

    when FAT_INIT_INFO:
        xprintf("\n    dwBPB_SecPerFats32 = %d",dwBPB_SecPerFats32)
        xprintf("\n    bBPB_NumFATs       = %d",bBPB_NumFATs)
        xprintf("\n    wBPB_RsvdSecCnt    = %d",wBPB_RsvdSecCnt)
        xprintf("\n    dwBPB_HiddSec      = %d",dwBPB_HiddSec)
        xprintf("\n    lgdwRootdir_sector = %d",lgdwRootdir_sector)
        xprintf("\n    lgwSize_of_root    = %d",lgwSize_of_root)
        xprintf("\n    lgwBPB_RootEntCnt  = %d",lgwBPB_RootEntCnt)
        xprintf("\n    lgbBPB_SecPerClus  = %d",lgbBPB_SecPerClus)
        xprintf("\n    lgwBPB_BytesPerSec = %d",lgwBPB_BytesPerSec)
        # while true:discard

# *****************
#  readDirEntry
# *****************
proc readDirEntry*(wDestDirEntryIndex: word) =
    var wCurrentDirEntryIndex: word = 0
    sd_start_read(lgdwRootdir_sector)
    when FILE_ENTRY_INFO:
        xprintf("\nFile entries(FENT) of 32byte are:")
    while true:
        for i in 0..<32: # ; read one dir entry
            lgbDirEntryBuff[i] = sd_data_byte()
        when FILE_ENTRY_INFO:
            xprintf("\nFENT: ")
            for i in 0..<32: # show dir entry with binary
                xprintf("%02X ", lgbDirEntryBuff[i])
            xprintf("\nasci: ")
            for i in 0..<32: # show dir entry with ascii
                let ch =  lgbDirEntryBuff[i]
                if (ch >= 0x20.byte) and (ch < 0x7f.byte):
                    xprintf(" %c ", ch)
                else:
                    xprintf("   ")

        if wCurrentDirEntryIndex == wDestDirEntryIndex:
            break
        wCurrentDirEntryIndex = wCurrentDirEntryIndex + 32
        if not lgfFat32:
            if wCurrentDirEntryIndex >= lgwSize_of_root:
                break
    sd_stop_read()


# *****************
#  searchNexFile
# *****************
proc searchNextFile*() =
    var topChar: byte
    var dwTargetClusterNumber: dword
    var wNextDirEntryIndex {.global.}: word = 0
    #  ; initialize
    if wNextDirEntryIndex != 0: #   ; if 0 , search first song
        wNextDirEntryIndex += 32
        # search next song
    while true: # ; start dir entry search
        # ; skip deleted entry
        while true:
            readDirEntry(wNextDirEntryIndex)
            topChar = lgbDirEntryBuff[0]
            if topChar == 0xE5: # ; skip deleted entry
                wNextDirEntryIndex += 32
            elif topChar == 0: # ; dir entry table is end, so return to the top entry
                wNextDirEntryIndex = 0
            else:
                break
        # ; check long file name
        if (topChar.int >= 0x42):
            if (topChar.int <= 0x54):
                if (lgbDirEntryBuff[11] and 0x0F) == 0x0F: # ; long file name ID(=0x0F) or not
                    # ; this is long file name, so set index to short file name address
                    wNextDirEntryIndex += ((word)((topChar - 0x40)).word shl 5)
                    readDirEntry(wNextDirEntryIndex)
        if (lgbDirEntryBuff[8] == 'W'.byte) and (lgbDirEntryBuff[9] == 'A'.byte) and
                (lgbDirEntryBuff[10] == 'V'.byte) and (lgbDirEntryBuff[11] == ' '.byte):
            #  ; lgbDirEntryBuff[11]=" ": (space) is the mark of archive attribute
            #  ; if the file extention matches 'WAV ', break
            #  -----------
            break
            # -----------
        wNextDirEntryIndex += 32
        # ; end while: dir entry search

    when UART_INFO:
        # -- print out music file name(short file name) to UART
        var fname {.noInit.}: array[13, byte]
        for i in  0..<8:
            fname[i] = lgbDirEntryBuff[i]
        fname[8] = '.'.byte
        fname[9] = lgbDirEntryBuff[8]
        fname[10] = lgbDirEntryBuff[9]
        fname[11] = lgbDirEntryBuff[10]
        fname[12] = 0
        when true: # true: Small size display , false: added music number
            xputc('\n'); xputs( cast[cstring](addr fname))
        else:
            var ix {.global.}: cint = 0
            xprintf("\n[%3d]: %s", ix, cast[cstring](addr fname))
            inc(ix)

    if lgfFat32:
        dwTargetClusterNumber += (lgbDirEntryBuff[20].dword shl 16)
        dwTargetClusterNumber += (lgbDirEntryBuff[21].dword shl 24)
    else:
        dwTargetClusterNumber = dwTargetClusterNumber and 0x0000FFFF.dword

    dwTargetClusterNumber += (lgbDirEntryBuff[26])
    dwTargetClusterNumber += (lgbDirEntryBuff[27].dword shl 8)

    lgdwBPB_FileSize  = (lgbDirEntryBuff[28]) #  file size
    lgdwBPB_FileSize += (lgbDirEntryBuff[29].dword shl 8)
    lgdwBPB_FileSize += (lgbDirEntryBuff[30].dword shl 16)
    lgdwBPB_FileSize += (lgbDirEntryBuff[31].dword shl 24)
    when FILE_ENTRY_INFO:
        xprintf("\nlgdwBPB_FileSize(Filesize) = %ld",lgdwBPB_FileSize)

    let dwRootdir_sector_size = (32.dword * (dword)(lgwBPB_RootEntCnt) +
                                                        lgwBPB_BytesPerSec - 1) div lgwBPB_BytesPerSec
    # ; calculate start sector of target song file
    gdwTargetFileSector = lgdwRootdir_sector + dwRootdir_sector_size +
            (dwTargetClusterNumber - 2) * lgbBPB_SecPerClus
    # ;include debug_info2

