################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
LD_SRCS += \
../src/lscript.ld 

C_SRCS += \
../src/RdSDImg.c \
../src/SetAdv7511.c \
../src/demo_yuv1080p.c \
../src/ff.c \
../src/mmc.c \
../src/platform.c 

OBJS += \
./src/RdSDImg.o \
./src/SetAdv7511.o \
./src/demo_yuv1080p.o \
./src/ff.o \
./src/mmc.o \
./src/platform.o 

C_DEPS += \
./src/RdSDImg.d \
./src/SetAdv7511.d \
./src/demo_yuv1080p.d \
./src/ff.d \
./src/mmc.d \
./src/platform.d 


# Each subdirectory must supply rules for building sources it contributes
src/%.o: ../src/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: ARM gcc compiler'
	arm-xilinx-eabi-gcc -Wall -O0 -g3 -c -fmessage-length=0 -MT"$@" -I../../standalone_bsp_0/ps7_cortexa9_0/include -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


