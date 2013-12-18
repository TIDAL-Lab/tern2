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

public class NXTWebServer extends WebSocketServer {
  
	private static int counter = 0;
  
  private NXTDriver robot;
	
	public NXTWebServer( int port , Draft d ) throws UnknownHostException {
		super( new InetSocketAddress( port ), Collections.singletonList( d ) );
    
    robot = new NXTDriver();
    robot.open("/dev/tty.NXT-DevB");
	}
	

	@Override
	public void onOpen( WebSocket conn, ClientHandshake handshake ) {
		counter++;
		System.out.println( "///////////Opened connection number" + counter );
    conn.send("@dart OPEN");
    if (robot.isConnected()) {
      conn.send("@dart FOUND NXT");
    }
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
    if ("@nxt CONNECT".equals(message)) {
      robot.open("/dev/tty.NXT-DevB");
      if (robot.isConnected()) {
        conn.send("@dart FOUND NXT");
      }
    } else {
      robot.doCommand(message);
  		conn.send( "@dart DONE" );
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
