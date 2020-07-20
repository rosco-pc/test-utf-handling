DAT programName          byte "TwoPwmCounters140905a", 0
CON
{{
  ******* Public Notes *******

  This object was written by Duane Degn
  Originally posted to the forum on July 9, 2014.

  For more information about this object see the following
  thread in the Parallax Forums:
  http://forums.parallax.com/showthread.php/156410
  
  See the data code for the date of the latest version.
  The data code includes the two digit year, two digit
  month, two digit day followed by a letter to indicate
  versions produced on the same day.
  
  The counter method used is almost a direct copy of
  from the Propeller Education Kit. There may be better
  ways to use the counters to generate PWM signals.

  This program requires input from a serial terminal to
  work correctly. The speeds of the motors are set
  by selecting the motor "a" or "b" and then entering
  the speed when prompted.

    **** Resolution and Frequency ****
    
  Both the resolution and the frequency used to generate
  the PWM signal are adjustable.

  When a new resolution is entered the target speed
  will be adjusted by the same proportion as the
  change in resolution. The changed speed may not
  be exactly the same proportion of the resolution
  after the change do to integer math rounding
  errors.

  The maximum frequency is is determined by the loop
  controlling the PWM in the method "PwmCounterSingle"
  or the method "PwmCounterDual". A single motor
  allows higher PWM frequencies than two motors.

  Since the counter used to generate the PWM signal
  can be set to the nearest clock tick, the maximum
  meaningful resolution is limited by the number
  or clock cycles within one PWM period. This value
  may be calculated by dividing the system's clock
  speed by the PWM frequency. For example, with a
  clock frequency of 80MHz and a PWM frequency of
  200Hz, the maximum resolution is 400,000
  (80,000,000 / 200). It is unlikely a resolution
  of more than 1000 would provide any increase in
  the ability to control the speed of a motor.

  The maximum frequency is above 20kHz which puts the
  frequency above the level heard by humans. If your
  h-bridge supports high frequencies 20kHz may be a
  good value to use.

  Many older h-bridge chips (L298, L293 or 754410) do not
  work well at high frequencies. In these cases a low
  frequency such as 200Hz may be a good idea since 
  low frequency noise tends to be less annoying than
  high frequency noise.

    **** Direction Control Pins ****
    
  The program was written with the intention it would
  be used with a L298N dual h-bridge (really a quad half bridge).
  This program should work with other h-bridges which use two
  direction pins and an enable pin for each motor.

  The program can also be used to control motors with a
  single direction control pin. Just set the second
  direction control pin to -1 if it isn't used.

    **** One or Two Motors ****
    
  The program may be used with either one or two motors. To
  disable the second motor set the value of "ENABLE_PIN_B"
  to -1. Only one counter will be used if a single motor
  is being controlled. A single motor may be controlled
  with a higher frequency than two motors.

  To use the program with a single direction control circuit
  (for example a transistor) set the "IN1_PIN" (or "IN1_PIN")
  to -1. When the program is using with a single direction
  control circuit the absolute value of the speed entered is
  used.
  
  
}}
{
  ******* Private Notes *******
  
  140707a Change name from "TwoPwmX131127e" to "TwoPwmSpin140707a".
  07a Start simplifying code.
  07b Change from waitcnt strategy to checking time differences.
  08b Appears to be working.
  08c Add ability to change resolution and frequency.
  08c Measure time of PwmLoop. (11,376 ticks)
  08d Remove timing portion.
  140707a Change name from "TwoPwmSpin140708d" to "TwoPwmCounters140708a".
  08a Start changing PWM from Spin loop to using counter modules.
  09b Add support to use with single direction pin.
  09c Find max frequency.
  140902a Modify to use with transistor drivers.
  02a The relationship between "pwmResolution" and
  "pwmTime" needs to be clarified.
  03c I don't think I'm calculating the maximum
  meaningful resolution correctly. I think this
  value may be much larger than the present
  calculations suggest.
  03d Added schematics started fixing resolution calculations.
  04a Fixed dual motor schematic. Fixed resolution calculations.
  04b Fixed typo in comments.
}
{{
-------------------------------------------------------------------------------
                      Motor Control with Transistor
                         (No direction control)

                                 Vmotor
                                    
                                    ┣──┐
                              Motor   │
                                    ┣┘ Flyback Diode     
                            1k? Ω   │    
             ENABLE_PIN_A ──────  NPN Transistor
     set IN1_PIN and IN2_PIN to -1  │        
                                    │
         or  ENABLE_PIN_B           │
     set IN3_PIN and IN4_PIN to -1   ground

    The motor's ground and the Propeller's ground need to be connected together.

    If ENABLE_PIN_B is used to control a transistor,
    then set IN3_PIN and IN4_PIN to -1.

    The resistor on the base will depend on the characteristics of the
    transistor and my need to be determined through experimentation.
    It's important to keep the current sourced by the Propeller to
    only 40mA.

    The motor supply ground and the Propeller's ground need to be connected together.
-------------------------------------------------------------------------------
                 Single Motor Control with L293D on
               Propeller Profesional Development Board
                         (no direction control)

                  3.3V or 5V
                       
     ENABLE_PIN_A ─┳─┼─ Enable (0,1)
               10kΩ  └─ Input 0
                    ┣─── Input 1
                    │    Input 2
                    │    Input 3
                    ┣─── Enable (2,3)
                    │    
                     ground
                                         Vmotor
                                           
                                   GND   ┐│
                                   Out 0 ┼┼──────────┳──┐
                                   Out 1 ┼┼─┐  Motor   │    
                                   Out 2 ││ └────────┻┘ Flyback Diode 
                                   Out 3 ││              (Possibly optional with the L293D)
                                   V+    ┼┘              
                                           ground
   set IN1_PIN and IN2_PIN to -1
   If only one motor is used (motor A) set ENABLE_PIN_B to -1

   The motor supply ground and the Propeller's ground need to be connected together.
-------------------------------------------------------------------------------
                 Single Motor Control with L293D on
               Propeller Professional Development Board
                       (with direction control)

              
     ENABLE_PIN_A ─┳─── Enable (0,1)
          IN1_PIN ─┼─── Input 0
          IN2_PIN ─┼─── Input 1
                    │    Input 2
                    │    Input 3
                    │ ┌─ Enable (2,3)
                    │ │
               10kΩ  │  
                    └─┫    
                       ground
                                         Vmotor
                                           
                                   GND   ┐│
                                   Out 0 ┼┼──────────┳──┐
                                   Out 1 ┼┼─┐  Motor   │    
                                   Out 2 ││ └────────┻──┘ 
                                   Out 3 ││           
                                   V+    ┼┘              
                                           ground
                                          
   ENABLE_PIN_A, IN1_PIN and IN2_PIN are set to I/O pins used to control the motor.
                                           
   If only one motor is used (motor A) set ENABLE_PIN_B to -1

   The motor supply ground and the Propeller's ground need to be connected together.
-------------------------------------------------------------------------------
                      Motor Control with L293D on
               Propeller Professional Development Board
                       (with direction control)

              
     ENABLE_PIN_A ─┳─── Enable (0,1)
          IN1_PIN ─┼─── Input 0
          IN2_PIN ─┼─── Input 1
          IN3_PIN ─┼─── Input 2
          IN4_PIN ─┼─── Input 3
     ENABLE_PIN_B ─┼─┳─ Enable (2,3)
                    │ │
               10kΩ   10kΩ
  A pull-down       └─┫    
  resistor is used     ground
  to keep motor                          Vmotor
  off during                               
  bootup.                          GND   ┐│ ┌────────┐
                                   Out 0 ┼┼─┘ MotorA   
                                   Out 1 ┼┼──────────┘
                                   Out 2 ┼┼──────────┐
                                   Out 3 ┼┼─┐ MotorB        
                                   V+    ┼┘ └────────┘
                                          │
                                           ground

   ENABLE_PIN_A, IN1_PIN and IN2_PIN are set to I/O pins used to control the motor A.

   ENABLE_PIN_B, IN3_PIN and IN4_PIN are set to I/O pins used to control the motor B.

   The motor supply ground and the Propeller's ground need to be connected together.
-------------------------------------------------------------------------------
                     Single Motor Control with L298N
        There are lot of inexpensive L298N boards available on ebay.
                         (no direction control)

                  3.3V or 5V
                       
     ENABLE_PIN_A ─┳─┼─ ENA (Leave pin behind ENA unconnected.)
               10kΩ  └─ IN1
  A pull-down       ┣─── IN2
  resistor is used  │    IN3
  to keep motor     │    IN4
  off during        ┣─── ENB (Leave pin behind ENB unconnected.)
  bootup.           │    
                     ground
           
          Vmotor(6V to 16V)             
                                             ┌────────┐   
                 │                     OUT1 ─┘         MotorA
                 │                     OUT2 ──────────┘
                 └─── +12V                                                
                 ┌─── GND             OUT3 X Not Connected
 +5V output ─────┼─── +5V             OUT4 X Not Connecte
 (optional, see  │                            
  5V regulator    ground                                        
  note below)                                    
                                          
   set IN1_PIN and IN2_PIN to -1
   If only one motor is used (motor A) set ENABLE_PIN_B to -1

   The motor supply ground and the Propeller's ground need to be connected together.
-------------------------------------------------------------------------------
                     Single Motor Control with L298N
        There are lot of inexpensive L298N boards available on ebay.
                       (with direction control)

              
     ENABLE_PIN_A ─┳─── ENA (Leave pin behind ENA unconnected.)  
          IN1_PIN ─┼─── IN1
          IN2_PIN ─┼─── IN2
                    │    IN3
  A pull-down       │    IN4
  resistor is used  │ ┌─ ENB (Leave pin behind ENB unconnected.)
  to keep motor     │ │
  off during   10kΩ  │  
  bootup.           └─┫    
                       ground
           
          Vmotor(6V to 16V)             
                                             ┌────────┐   
                 │                     OUT1 ─┘         MotorA
                 │                     OUT2 ──────────┘
                 └─── +12V                                                
                 ┌─── GND             OUT3 X Not Connected
 +5V output ─────┼─── +5V             OUT4 X Not Connecte
 (optional, see  │                            
  5V regulator    ground                                        
  note below)                                    
                                          
   ENABLE_PIN_A, IN1_PIN and IN2_PIN are set to I/O pins used to control the motor.
                                           
   If only one motor is used (motor A) set ENABLE_PIN_B to -1

   The motor supply ground and the Propeller's ground need to be connected together.   
-------------------------------------------------------------------------------
                     Dual Motor Control with L298N
        There are lot of inexpensive L298N boards available on ebay.
                       (with direction control)

              
     ENABLE_PIN_A ─┳─── ENA (Leave pin behind ENA unconnected.)  
          IN1_PIN ─┼─── IN1
          IN2_PIN ─┼─── IN2
          IN3_PIN ─┼─── IN3
          IN4_PIN ─┼─── IN4
     ENABLE_PIN_B ─┼─┳─ ENB (Leave pin behind ENB unconnected.)
                    │ │
               10kΩ   10kΩ
                    └─┫    
                       ground


          Vmotor(6V to 16V)             
                                             ┌────────┐   
                 │                     OUT1 ─┘         MotorA
                 │                     OUT2 ──────────┘
                 └─── +12V                                                
                 ┌─── GND             OUT3 ──────────┐            
 +5V output ─────┼─── +5V             OUT4 ─┐         MotorB
 (optional, see  │                            └────────┘
  5V regulator    ground                                        
  note below)                          
  
   ENABLE_PIN_A, IN1_PIN and IN2_PIN are set to I/O pins used to control the motor A.

   ENABLE_PIN_B, IN3_PIN and IN4_PIN are set to I/O pins used to control the motor B.

   The motor supply ground and the Propeller's ground need to be connected together. 
-------------------------------------------------------------------------------                                  
  *** L298N 5V Regulator Note ***                                             
  Many L298N boards have a 5V regulator which allows the boards to be powered with a single voltage
  source.
  This 5V regulator can source 100mA of current and can power a low current device.
  Low power Propeller boards such as the QuickStart may be powered from the 5V regulator by connecting
  the 5V source to the Vin pin (position 40 on the 40 position header) on the QuickStart board.
-------------------------------------------------------------------------------                                  
}}
CON ' timing constants

  _clkmode = xtal1 + pll16x 
  _xinfreq = 5_000_000

  CLK_FREQ = ((_clkmode - xtal1) >> 6) * _xinfreq
  MICROSECOND = CLK_FREQ / 1_000_000
  MILLISECOND = CLK_FREQ / 1_000

CON ' pin assignments and other constant user may change

  ENABLE_PIN_A = 0             '' user changable
  IN1_PIN = 1                  '' user changable
  IN2_PIN = 2                  '' user changable
  ' Set IN1_PIN to -1 if no direction pin is used (when using a transistor).
  ' Set IN2_PIN to -1 if using a single direction pin.
  
  ENABLE_PIN_B = -1             '' user changable
  IN3_PIN = -1                  '' user changable
  IN4_PIN = -1                  '' user changable
  ' Set ENABLE_PIN_B to -1 if no direction pin is used (when using a transistor).
  ' Set IN3_PIN to -1 if no direction pin is used (when using a transistor).
  ' Set IN4_PIN to -1 if using a single direction pin.

  MIN_ALLOWED_FREQUENCY =  1    '' user changable 
  MIN_ALLOWED_RESOLUTION =  1   '' user changable 

  DEBUG_BAUD = 115_200          '' user changable

  DEFAULT_PWM_FREQUENCY = 200   '' user changable
  DEFAULT_PWM_RESOLUTION = 1000 '' user changable

CON

  QUOTE = 34
  MOTORS_USED = 2               ' This is not user changable. 
  MAX_MOTOR_INDEX = MOTORS_USED - 1
                  
  MAX_ALLOWED_FREQUENCY_SINGLE = 38_700 '38_750 ' This is not exact.
  ' The value of "MAX_ALLOWED_FREQUENCY_SINGLE" can vary with speed.
  MAX_ALLOWED_FREQUENCY_DUAL =  27_472 ' exact at 80MHz 
  '' The MAX_ALLOWED_FREQUENCY is limited by the loop in the
  '' method "PwmCounter". Since the loop takes 2,912 clock
  '' cycles , the maximum frequency is 80,000,000 / 2,912
  '' = 27,472Hz. I actually calculated the loop time from the
  '' highest frequency which didn't cause the program to
  '' freeze.
  ''
  '' The maximum resolution at a given frequency is the
  '' number of clock cycles within one PWM period.
  '' At 200Hz there are (80,000,000 / 200) or 400,000 clock
  '' per period so the maximum resolution at 200Hz is 400,000.
  '' The maximum frequency could be higher when using a
  '' single motor but presently the program doesn't adjust
  '' the maximum frequency when a single motor is used.
  

  '' The "RES_AT_MAX_FREQ_X" constants indicate the lowest resolution
  '' possible. This resolution limit applies when the "MAX_ALLOWED_FREQUENCY_"
  '' is used as the pwmFrequency.
  RES_AT_MAX_FREQ_SINGLE = CLK_FREQ / MAX_ALLOWED_FREQUENCY_SINGLE 
  RES_AT_MAX_FREQ_DUAL = CLK_FREQ / MAX_ALLOWED_FREQUENCY_DUAL
  
  #0, MOTOR_A, MOTOR_B  '' Do not change

  ' mode enumeration also used for maximum motor index
  #0, SINGLE_MODE, DUAL_MODE  '' Do not change
  
VAR

  long pwmCogStack[50] ' stack size not optimized
  long pwmOnTime[MOTORS_USED], pwmTime
  long pwmFrequency, pwmResolution
  long targetSpeed[MOTORS_USED]
  long currentMaxFreq

  byte mode
     
OBJ 

  Pst : "Parallax Serial Terminal"
 
PUB Setup
'' This setup method will only set I/O pin states used by cog #0.
'' Each cog needs to set it's own I/O pin states and counter configurations.
'' The counters of cog #0 are not used.

  Pst.Start(DEBUG_BAUD)
  SetFrequency(DEFAULT_PWM_FREQUENCY)
  SetResolution(DEFAULT_PWM_RESOLUTION)
  targetSpeed[MOTOR_A] := 0
  targetSpeed[MOTOR_B] := 0

  if enablePins[MOTOR_B] == -1
    mode := SINGLE_MODE ' mode can also be used as the maximum motor index
  else
    mode := DUAL_MODE
    
  ' set motor control pins to outputs
  '' I/O pins should (in general) only be set from a single cog.
  '' The direction pins will be set only from this cog.
  '' The enable pins will be set from a different cog.
  '' This is an important aspect of programming the Propeller.
  if forwardPins[MOTOR_A] <> -1
    dira[forwardPins[MOTOR_A]] := 1
    'bidirectionalFlag[MOTOR_A] := 1
    if reversePins[MOTOR_A] <> -1
      dira[reversePins[MOTOR_A]] := 1

  if mode ' same as "if mode <> 0" or "if mode <> SINGLE_MODE" since SINGLE_MODE equals zero   
    if forwardPins[MOTOR_B] <> -1       
      dira[forwardPins[MOTOR_B]] := 1
      'bidirectionalFlag[MOTOR_B] := 1
      if reversePins[MOTOR_B] <> -1
        dira[reversePins[MOTOR_B]] := 1
    
  repeat
    Pst.str(string(13, "Press any key to start."))
    waitcnt(clkfreq / 2 + cnt)
    result := Pst.RxCount
  until result

  RefreshSpeed

  Pst.RxFlush
  Pst.Clear
  Pst.str(string(13, "programName = ")) ' I like to know which program is loaded in the Propeller. 
  Pst.str(@programName)
  Pst.str(string(13, "The method ", QUOTE, "PwmCounter"))
  ' I use the constant "QUOTE" in order to display the double quote character (ASCII 34).
  
  if ENABLE_PIN_B == -1
    result := cogNew(PwmCounterSingle, @pwmCogStack)
    Pst.str(string("Single"))                                             
  else    
    result := cogNew(PwmCounterDual, @pwmCogStack) ' "result" is used as a temporary variable.
                                                   ' each method has this variable automatically.
    Pst.str(string("Dual"))                                                
  Pst.str(string(QUOTE, " as been started in cog # "))
  ' I use the constant "QUOTE" in order to display the double quote character (ASCII 34).
  
  Pst.dec(result) ' probably cog #2 since cog #1 was used by the serial object
  ' It's generally a good idea to only transmit with the serial object (PST) from
  ' a single cog. Otherwise the communication will be garbled when two cogs try to send
  ' data at the same time.
    
  MainLoop
  
PUB MainLoop 

  RefreshSpeed
  DisplayTargetSpeed
  DisplayMainMenu
  
  repeat
    result := Pst.RxCount
    if result
      result := Pst.CharIn
      case result
        "a", "A":
          InputSpeed(MOTOR_A)
          RefreshSpeed
        "b", "B":
          if mode == SINGLE_MODE
            NotValid(result) 
          else
            InputSpeed(MOTOR_B)
            RefreshSpeed
        "f", "F":
          InputFrequency
          RefreshSpeed
        "r", "R":
          InputResolution
          RefreshSpeed
        "0", "o", "O", "x", "X":
          StopMotors
        "c", "C":
          Pst.Clear
        other:
          NotValid(result)
      DisplayTargetSpeed
      DisplayMainMenu
      
PRI NotValid(inputCharacter)

  Pst.str(string(13, "The character ", QUOTE))
  Pst.Char(inputCharacter)
  Pst.str(string(QUOTE, " is not a valid option."))
          
PUB DisplayMainMenu

  Pst.str(string(13, "Enter one of the following characters:"))
  Pst.str(string(13, "a) to change speed of motor A"))
  if mode == DUAL_MODE
    Pst.str(string(13, "b) to change speed of motor B"))
  Pst.str(string(13, "f) to change pwm Frequency"))
  Pst.str(string(13, "r) to change pwm Resolution"))
  Pst.str(string(13, "c) to Clear window"))
  Pst.str(string(13, "0 or x) to stop both motors"))

PRI DisplayTargetSpeed  

  DisplayPwmParameters
  Pst.str(string(13, "Target Speeds:"))
  repeat result from 0 to mode 
    Pst.str(string(13, "targetSpeed["))
    Pst.dec(result)
    Pst.str(string("] = "))
    Pst.dec(targetSpeed[result])
    Pst.ClearEnd
 
PRI DisplayPwmParameters 

  Pst.str(string(13, 13, "The current PWM frequency is "))
  Pst.dec(pwmFrequency)
  Pst.str(string(" Hz."))
  Pst.str(string(13, "The current PWM resolution is "))
  Pst.dec(pwmResolution)
  Pst.Char(".")
         
PUB InputSpeed(motorIndex)

  Pst.str(string(13, 13, "  *** Enter Speed ***"))
  Pst.str(string(13, "Please input the desired speed of motor "))
  Pst.Char(GetMotorCharacter(motorIndex))
      
  Pst.str(string(13, "Enter a number between "))
  Pst.dec(pwmResolution * -1)
  Pst.str(string(" and +"))
  Pst.dec(pwmResolution)
  Pst.Char(".")
  result := Pst.DecIn
  if result < pwmResolution * -1 or result > pwmResolution
    Pst.str(string(13, "The value entered ", QUOTE))
    Pst.dec(result)
    Pst.str(string(QUOTE, " is not within allowed range."))
    Pst.str(string(13, "The motor speed will not be changed."))
    result := 0
  else
    Pst.str(string(13, "The motor speed was successfully changed.")) 
    targetSpeed[motorIndex] := result 
    result := 1

PUB InputFrequency 

  Pst.str(string(13, 13, "*** Change PWM Frequency Method ***"))
  DisplayPwmParameters

  Pst.str(string(13, "The frequency needs to be between "))
  Pst.dec(MIN_ALLOWED_FREQUENCY) 
  Pst.str(string(" Hz and "))
  Pst.dec(maxAllowedFreq[mode]) 
  Pst.str(string(" Hz."))
  if currentMaxFreq < maxAllowedFreq[mode]
    Pst.str(string(13, "The current resolution of "))
    Pst.dec(pwmResolution) 
    Pst.str(string(" can only be maintained with frequencies of "))
    Pst.dec(currentMaxFreq) 
    Pst.str(string(" Hz or lower."))     
  Pst.str(string(13, "Please input the desired PWM frequency."))
  
  result := Pst.DecIn
 
  if result < MIN_ALLOWED_FREQUENCY
    Pst.str(string(13, "The frequency entered "))
    Pst.dec(result) 
    Pst.str(string(" Hz is loweer than the minimum allowed frequency of "))
    Pst.dec(MIN_ALLOWED_FREQUENCY) 
    Pst.str(string(" Hz."))
    Pst.str(string(13, "The frequency will be set to this minimum value."))
    result := MIN_ALLOWED_FREQUENCY
  elseif result > maxAllowedFreq[mode]
    Pst.str(string(13, "The frequency entered "))
    Pst.dec(result) 
    Pst.str(string(" Hz is higher than the max allowed frequency of "))
    Pst.dec(maxAllowedFreq[mode]) 
    Pst.str(string(" Hz."))
    Pst.str(string(13, "The frequency will be set to this maximum value."))
    result := maxAllowedFreq[mode]
  else
    Pst.str(string(13, "The frequency entered "))
    Pst.dec(result) 
    Pst.str(string("Hz will be used."))

  result := SetFrequency(result)

  if result == pwmResolution
    Pst.str(string(13, "The current resolution will be maintained at this new frequency."))
    Pst.str(string(13, "The current resolution is the maximum possible at this new frequency."))
  elseif result < pwmResolution   
    Pst.str(string(13, "The current resolution will not be maintained at this new frequency."))
    Pst.str(string(13, "The current resolution will still be used for speed input but not "))
    Pst.str(string("all speed settings will be unique."))
  else  
    Pst.str(string(13, "The current resolution will be maintained at this new frequency."))
    Pst.str(string(13, "The maximun resolution possible at this new frequency is "))
    Pst.dec(result)
    Pst.str(string(13, "The maximum frequency possible with the current resolution is "))
    result := clkfreq / pwmResolution
    if result > maxAllowedFreq[mode]
      Pst.str(string("the program maximum of "))
      result := maxAllowedFreq[mode] 
    Pst.dec(result)
    Pst.str(string(" Hz."))  
  
       
PUB InputResolution | motorIndex

  Pst.str(string(13, 13, "*** Change PWM Resolution Method ***"))
  DisplayPwmParameters
  
  Pst.str(string(13, "The maximum resolution at this frequnecy is "))
  Pst.dec(pwmTime) 
  Pst.Char(".")
  Pst.str(string(13, "A higher resolution value may be used for speed control but if a higher value"))
  Pst.str(string(13, "is used, it will not reflect the actual resolution of the PWM signal."))
  Pst.str(string(13, "Please input the desired PWM resolution."))
    
  result := Pst.DecIn
  if result < MIN_ALLOWED_RESOLUTION
    Pst.str(string(13, "The PWM resolution entered ", QUOTE))
    Pst.dec(result) 
    Pst.str(string(QUOTE, " is less than the minimum allowed of ", QUOTE))
    Pst.dec(MIN_ALLOWED_RESOLUTION) 
    Pst.str(string(QUOTE, ". The PWM resolution will not be channged."))
    return
  Pst.str(string(13, "Adjusting speeds to new resolution."))
  repeat motorIndex from MOTOR_A to mode
    Pst.str(string(13, "Motor "))
    Pst.Char(GetMotorCharacter(motorIndex))
    Pst.str(string(" speed at resolution "))
    Pst.dec(pwmResolution) 
    Pst.str(string(" was "))    
    Pst.dec(targetSpeed[motorIndex]) 
    Pst.str(string(". Speed at new resolution of "))    
    Pst.dec(result) 
    Pst.str(string(" will be "))
    targetSpeed[motorIndex] := TtaMethod(targetSpeed[motorIndex], result, pwmResolution)  
    Pst.dec(targetSpeed[motorIndex]) 
    Pst.Char(".")
    
  result := SetResolution(result)
  
  if result == pwmFrequency
    Pst.str(string(13, "The new resolution is the maximum possible at the current frequency."))
  elseif result < pwmFrequency   
    Pst.str(string(13, "The new resolution will not be maintained at this new frequency."))
    Pst.str(string(13, "The new resolution will be used for speed input but not "))
    Pst.str(string("all speed settings will be unique."))
    Pst.str(string(13, "The the present frequency will not support a resolution of "))
    Pst.dec(pwmResolution) 
    Pst.str(string(".", 13, "The maximum resolution possible at the current frequency is "))
    Pst.dec(pwmTime) 
    Pst.str(string("."))  
  else  
    Pst.str(string(13, "The new resolution will be used at the current frequency."))
    Pst.str(string(13, "The maximun frequency possible at this new resolution is "))
    Pst.dec(result) 
    Pst.str(string(" Hz."))  
               
PUB GetMotorCharacter(motorIndex)
'' Used to display motor channel IDs.

  case motorIndex
    MOTOR_A:
      result := "A"
    MOTOR_B:
      result := "B"
    other:
      result := "?"
      
PUB SetFrequency(localFrequency)
'' This method sets the PWM frequency (within limits).
'' This method returns the maximum possible resolution
'' possible at the new frequency. This method does not
'' change the resolution.

  pwmFrequency := localFrequency <# maxAllowedFreq[mode]
  pwmTime := clkfreq / pwmFrequency
  result := pwmTime ' pwmTime is also the maximum resolution possible at
                    ' the new frequency.
  
PUB SetResolution(localResolution)
'' Setting a resolution will not gaurantee the resolution will be
'' achieved. The resolution will be limited by the both the
'' frequency and the amount of time to complete a loop in the
'' "PwmLoop" method.
'' The frequency will not be changed to allow the new resolution.
'' The new resolution will still be used for speed control but
'' each speed value will not create a unique pulse time.
'' This method returns the maximum frequency possible at the
'' new resolution. This method does not change the frequency.

  pwmResolution := localResolution
  result := (clkfreq / pwmResolution) <# maxAllowedFreq[mode]
  currentMaxFreq := result
  
PUB StopMotors

  targetSpeed[MOTOR_A] := 0
  targetSpeed[MOTOR_B] := 0
  RefreshSpeed
  
PUB RefreshSpeed

  SetOnTimes(targetSpeed[MOTOR_A], targetSpeed[MOTOR_B])
  
PUB SetOnTimes(speedMotorA, speedMotorB)
'' This method must be called from the
'' same cog which set the pin directions.
'' If at least one direction pin is used,
'' then a negative speed will cause the
'' motor to spin in the opposite direction
'' as a positive speed.
'' If no direction pin is used (when using
'' a transistor instead of a h-bridge) then
'' the absolute value of the speed will be
'' used.

  if speedMotorA > 0
    if forwardPins[MOTOR_A] <> -1
      outa[forwardPins[MOTOR_A]] := 1
      if reversePins[MOTOR_A] <> -1
        outa[reversePins[MOTOR_A]] := 0
  else
    if forwardPins[MOTOR_A] <> -1
      outa[forwardPins[MOTOR_A]] := 0
      if reversePins[MOTOR_A] <> -1
        outa[reversePins[MOTOR_A]] := 1
    -speedMotorA 

  if speedMotorA == 0
    pwmOnTime[MOTOR_A] := 0
  elseif speedMotorA => pwmResolution
    pwmOnTime[MOTOR_A] := pwmTime
  else
    pwmOnTime[MOTOR_A] := TtaMethod(pwmTime, speedMotorA, pwmResolution)

  if mode
    if speedMotorB > 0
      if forwardPins[MOTOR_B] <> -1
        outa[forwardPins[MOTOR_B]] := 1
        if reversePins[MOTOR_B] <> -1
          outa[reversePins[MOTOR_B]] := 0
    else
      if forwardPins[MOTOR_B] <> -1
        outa[forwardPins[MOTOR_B]] := 0
        if reversePins[MOTOR_B] <> -1
          outa[reversePins[MOTOR_B]] := 1
      -speedMotorB
       
    if speedMotorB == 0
      pwmOnTime[MOTOR_B] := 0
    elseif speedMotorB => pwmResolution
      pwmOnTime[MOTOR_B] := pwmTime
    else
      pwmOnTime[MOTOR_B] := TtaMethod(pwmTime, speedMotorB, pwmResolution)

PRI TtaMethod(N, X, D)   ' return X*N/D where all numbers and result are positive =<2^31
'' Method written by Tracy Allen to deal with large numbers.

  return (N / D * X) + (binNormal(N//D, D, 31) ** (X*2))

PRI BinNormal (y, x, b) : f                  ' calculate f = y/x * 2^b
' b is number of bits
' enter with y,x: {x > y, x < 2^31, y <= 2^31}
' exit with f: f/(2^b) =<  y/x =< (f+1) / (2^b)
' that is, f / 2^b is the closest appoximation to the original fraction for that b.
  repeat b
    y <<= 1
    f <<= 1
    if y => x    '
      y -= x
      f++
  if y << 1 => x    ' Round off. In some cases better without.
      f++

PRI PwmCounterSingle | cycleTimer  
'' Based on chapter 7 of the Propeller Education Kit (PEK).
'' I copied what was done in chapter 7.
'' Counters and I/O pin states should be set from within the cog
'' using the counters and pins.
'' A single PWM channel allows higher frequencies than
'' two PWM channels.
'' See the value of "MAX_ALLOWED_FREQUENCY_SINGLE" for the
'' maximun frequency possible with a single channel.

  ctra[30..26] := %00100        ' Configure Counters to NCO                   
  ctra[5..0] := enablePins[MOTOR_A]
  frqa := 1

  dira[enablePins[MOTOR_A]] := 1

  cycleTimer := cnt             ' Mark counter time
  repeat                        ' Repeat PWM signal
    phsa := -pwmOnTime[MOTOR_A] ' Set up the pulses 
    cycleTimer += pwmTime       ' Calculate next cycle repeat
    waitcnt(cycleTimer)         ' Wait for next cycle

PRI PwmCounterDual | cycleTimer  
'' Based on chapter 7 of the Propeller Education Kit (PEK).
'' I copied what was done in chapter 7 and did the same
'' sort of thing with the second counter.
'' Counters and I/O pin states should be set from within the cog
'' using the counters and pins.
'' A two PWM channel can not produce as high of frequencies 
'' as a single PWM channel.
'' See the value of "MAX_ALLOWED_FREQUENCY_DUAL" for the
'' maximun frequency possible with two channels.

  ctra[30..26] := %00100        ' Configure Counters to NCO
  ctrb[30..26] := %00100                    
  ctra[5..0] := enablePins[MOTOR_A]
  ctrb[5..0] := enablePins[MOTOR_B]
  frqa := 1
  frqb := 1

  dira[enablePins[MOTOR_A]] := 1
  dira[enablePins[MOTOR_B]] := 1

  cycleTimer := cnt             ' Mark counter time
  repeat                        ' Repeat PWM signal
    phsa := -pwmOnTime[MOTOR_A] ' Set up the pulses
    phsb := -pwmOnTime[MOTOR_B] 
    cycleTimer += pwmTime       ' Calculate next cycle repeat
    waitcnt(cycleTimer)         ' Wait for next cycle

DAT

' pin arrays
' I list the pin assignments in the DAT section so they can be used by their index number.
' This sort of strategy becomes a greater advantage when more than two motors are used.

enablePins              long ENABLE_PIN_A, ENABLE_PIN_B
forwardPins             long IN1_PIN, IN3_PIN
reversePins             long IN2_PIN, IN4_PIN
maxAllowedFreq          long MAX_ALLOWED_FREQUENCY_SINGLE, MAX_ALLOWED_FREQUENCY_DUAL
resolutionAtMaxFreq     long RES_AT_MAX_FREQ_SINGLE, RES_AT_MAX_FREQ_DUAL
            
DAT '' License
{{
*********************************************************************************************
*                             TERMS OF USE: MIT License                                     *                                                                   
*********************************************************************************************
* Permission is hereby granted, free of charge, to any person obtaining a copy of this      *
* software and associated documentation files (the "Software"), to deal in the Software     *
* without restriction, including without limitation the rights to use, copy, modify,        *
* merge, publish, distribute, sublicense, and/or sell copies of the Software, and to        *
* permit persons to whom the Software is furnished to do so, subject to the following       *
* conditions:                                                                               *
*                                                                                           *                                    
* The above copyright notice and this permission notice shall be included in all copies or  *
* substantial portions of the Software.                                                     *
*                                                                                           *                                   
* The software is provided "as is", without warranty of any kind, express or implied,       *
* including but not limited to the warranties of merchantability, fitness for a particular  *
* and noninfringment. In no event shall the authors or copyright holders be liable for any  *
* claim, damages or other liability, whether in an action of contract, tort or otherwise,   *
* arising from, of or in connection with the software of the use of other dealings in the   *
* software.                                                                                 *
*********************************************************************************************
}}        
