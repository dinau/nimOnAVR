# This Makefile builds all expamle projects at a time.

EX1 = example1
EX2 = example2
SAMPLE_DIRS :=	$(EX1)/led \
				$(EX1)/nimOnArduino \
				$(EX1)/uart \
				$(EX1)/uart_led \
				$(EX1)/struct_test_cmake \
				$(EX2)/intr_test \
				$(EX2)/sd_card

all: clean
	$(foreach exdir,$(SAMPLE_DIRS), $(call def_make,$(exdir) ) )

clean:
	$(foreach exdir,$(SAMPLE_DIRS), $(call def_clean,$(exdir) ))
	@$(MAKE) -C $(EX1)/struct_test_cmake cleanall

# definition loop funciton
define def_make
	@-$(MAKE) -C $(1) clean all

endef

define def_clean
	@-$(MAKE) -C $(1) clean

endef

