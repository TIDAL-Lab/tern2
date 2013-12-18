
import java.io.IOException;
import java.io.OutputStream;
import gnu.io.NRSerialPort;

public class NXTDriver {
  
  public static final int MOTOR_A = 0;
  public static final int MOTOR_B = 1;
  public static final int MOTOR_C = 2;
  
  private OutputStream nxtOut;
  private NRSerialPort serial;
  
  
  public NXTDriver() {
    this.nxtOut = null;
    this.serial = null;
  }
  
  
  public void open(String descriptor) {
    System.out.println("Connecting to NXT...");
    serial = new NRSerialPort(descriptor, 115200);
    if (serial.connect()) {
      nxtOut = serial.getOutputStream();
      System.out.println("success.");
    } else {
      System.err.println("failed.");
      serial = null;
      nxtOut = null;
    }
  }

  
  public void close() {
    if (serial != null) {
      serial.disconnect();
    }
    serial = null;
    nxtOut = null;
  }
  
  
  boolean isConnected() {
    return serial != null;
  }
  
  
  public void doCommand(String command) {
    System.out.println("---------- " + command.toUpperCase() + " ----------");
    if ("sing".equalsIgnoreCase(command)) {
      doBeep(392, 100, 200);
      doBeep(440, 100, 200);
      doBeep(494, 100, 200);
      doBeep(523, 100, 200);
      doBeep(587, 300, 400);
      doBeep(523, 300, 400);
      doBeep(494, 300, 500);
    }
    
    else if ("beep".equalsIgnoreCase(command)) {
      doBeep(494, 400, 800);
      doBeep(440, 400, 800);
    }
    
    else if ("forward".equalsIgnoreCase(command)) {
      doStartMotor(MOTOR_A, 50);
      doStartMotor(MOTOR_C, 50);
      pause(1500);
      doStopMotor(MOTOR_A);
      doStopMotor(MOTOR_C);
      pause(500);
    }
    
    else if ("backward".equalsIgnoreCase(command)) {
      doStartMotor(MOTOR_A, -50);
      doStartMotor(MOTOR_C, -50);
      pause(1500);
      doStopMotor(MOTOR_A);
      doStopMotor(MOTOR_C);
      pause(500);
    }
    
    else if ("left".equalsIgnoreCase(command)) {
      doStartMotor(MOTOR_C, 75);
      doStartMotor(MOTOR_A, -40);
      pause(800);
      doStopMotor(MOTOR_A);
      doStopMotor(MOTOR_C);
      pause(500);
    }
    
    else if ("right".equalsIgnoreCase(command)) {
      doStartMotor(MOTOR_A, 75);
      doStartMotor(MOTOR_C, -40);
      pause(800);
      doStopMotor(MOTOR_A);
      doStopMotor(MOTOR_C);
      pause(500);
    }
    
    else if ("spin".equalsIgnoreCase(command)) {
      doStartMotor(MOTOR_A, 75);
      doStartMotor(MOTOR_C, -75);
      pause(2667);
      doStopMotor(MOTOR_A);
      doStopMotor(MOTOR_C);
      pause(1000);
    }
    
    else if ("shake".equalsIgnoreCase(command)) {
      int pa = 100;
      int pc = -100;
      for (int i=0; i<10; i++) {
        doStartMotor(MOTOR_A, pa);
        doStartMotor(MOTOR_C, pc);
        pause(200);
        pa *= -1;
        pc *= -1;
      }
      doStopMotor(MOTOR_A);
      doStopMotor(MOTOR_C);
      pause(500);
    }
    
    else if ("wiggle".equalsIgnoreCase(command)) {
      for (int i=0; i<5; i++) {
        doStartMotor(MOTOR_A, 100);
        doStartMotor(MOTOR_C, 10);
        pause(200);
        doStartMotor(MOTOR_A, 10);
        doStartMotor(MOTOR_C, 100);
        pause(200);
      }
      doStopMotor(MOTOR_A);
      doStopMotor(MOTOR_C);
      pause(500);
    }
    
    else {
      pause(200);
    }
  }

  
  private void sendMessage(byte [] message) {
    try {
      if (nxtOut != null) {
        int length = message.length;
        nxtOut.write(length);
        nxtOut.write(length >> 8);
        nxtOut.write(message, 0, message.length);
      }
    } catch (IOException iox) {
      iox.printStackTrace();
    }
  }
  
  
  private void doBeep(int frequency, int duration, int millis) {
    byte [] message = LCPMessage.getBeepMessage(frequency, duration);
    sendMessage(message);
    pause(millis);
  }
  
  
  private void doStartMotor(int motor, int speed) {
    if (speed > 100) speed = 100;
    if (speed < -100) speed = -100;
    byte [] message = LCPMessage.getMotorMessage(motor, speed);
    sendMessage(message);
  }
  
  
  private void doStopMotor(int motor) {
    byte [] message = LCPMessage.getMotorMessage(motor, 0);
    sendMessage(message);
  }
  
  
  public static void pause(int millis) {
    try { Thread.sleep(millis); }
    catch (InterruptedException x) { ; }
  }
  
  
  public static void main(String [] args) {
    NXTDriver driver = new NXTDriver();
    driver.open("/dev/tty.NXT-DevB");
    pause(100);
    driver.doCommand("beep");
    driver.doCommand("wiggle");
    driver.doCommand("forward");
    driver.close();
  }
}