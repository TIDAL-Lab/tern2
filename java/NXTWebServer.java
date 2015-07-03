import java.net.InetSocketAddress;
import java.net.UnknownHostException;
import java.nio.ByteBuffer;
import java.util.Collections;

import org.java_websocket.WebSocket;
import org.java_websocket.WebSocketImpl;
import org.java_websocket.drafts.Draft;
import org.java_websocket.drafts.Draft_17;
import org.java_websocket.framing.FrameBuilder;
import org.java_websocket.framing.Framedata;
import org.java_websocket.handshake.ClientHandshake;
import org.java_websocket.server.WebSocketServer;

import java.io.File;
import java.io.FileOutputStream;
import java.io.BufferedReader;
import java.io.InputStreamReader;



public class NXTWebServer extends WebSocketServer {
  
	private static int counter = 0;
  
	public NXTWebServer( int port , Draft d ) throws UnknownHostException {
    super( new InetSocketAddress( port ), Collections.singletonList( d ) );
	}
	

	@Override
	public void onOpen( WebSocket conn, ClientHandshake handshake ) {
		counter++;
		System.out.println( "///////////Opened connection number" + counter );
    conn.send("@dart OPEN");
	}

  
	@Override
	public void onClose( WebSocket conn, int code, String reason, boolean remote ) {
		System.out.println( "closed" );
	}

  
	@Override
	public void onError( WebSocket conn, Exception ex ) {
		System.out.println( "Error:" );
		ex.printStackTrace();
	}

  
	@Override
	public void onMessage( WebSocket conn, String message ) {
    if (message.startsWith("@compile ")) {
      System.out.println(message);

      // First write the hook.cpp file out
      try {
        FileOutputStream fout = new FileOutputStream("arduino/hook.cpp");
        fout.write(message.substring(9).getBytes());
        fout.close();
        System.out.println("wrote hook");
      }
      catch (Exception x) {
        System.out.println(x);
      }

      // Touch the main CPP file to trigger a rebuild
      try {
        String s;
        ProcessBuilder pb = new ProcessBuilder("touch", "redbot.cpp");
        pb.directory(new File("arduino"));
        Process p = pb.start();
        BufferedReader stdInput = new BufferedReader(
          new InputStreamReader(p.getInputStream()));
        while ((s = stdInput.readLine()) != null) {
          System.out.println(s);
        }
      } catch (Exception x) {
        System.out.println(x);
      }

      // Then run the makefile
      try {
        String s;
        ProcessBuilder pb = new ProcessBuilder("make", "build", "upload");
        pb.directory(new File("arduino"));
        Process p = pb.start();
        BufferedReader stdInput = new BufferedReader(
          new InputStreamReader(p.getInputStream()));
        while ((s = stdInput.readLine()) != null) {
          System.out.println(s);
        }

        conn.send("@dart SUCCESS");
      } catch (Exception x) {
        System.out.println(x);
      }
    }
	}

  
	@Override
	public void onMessage( WebSocket conn, ByteBuffer blob ) {
		conn.send( blob );
	}

  
	public void onWebsocketMessageFragment( WebSocket conn, Framedata frame ) {
		FrameBuilder builder = (FrameBuilder) frame;
		builder.setTransferemasked( false );
		conn.sendFrame( frame );
	}

  
	public static void main( String[] args ) throws  UnknownHostException {
		WebSocketImpl.DEBUG = false;
		int port;
		try {
			port = new Integer( args[ 0 ] );
		} catch ( Exception e ) {
			System.out.println( "No port specified. Defaulting to 9003" );
			port = 9003;
		}
		new NXTWebServer( port, new Draft_17() ).start();
	}
}
