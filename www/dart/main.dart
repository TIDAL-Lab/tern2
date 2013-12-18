/*
 * Roberto StickerBook
 * Copyright (c) 2013 Michael S. Horn
 * 
 *           Michael S. Horn (michael-horn@northwestern.edu)
 *           Northwestern University
 *           2120 Campus Drive
 *           Evanston, IL 60613
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License (version 2) as
 * published by the Free Software Foundation.
 * 
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */
library StickerBook;

import 'dart:html';
import 'dart:math';
import 'dart:async';
import 'dart:web_audio';

part 'compiler.dart';
part 'connector.dart';
part 'factory.dart';
part 'program.dart';
part 'scanner.dart';
part 'sounds.dart';
part 'statement.dart';
part 'topcode.dart';
part 'utils.dart';


const VIDEO_WIDTH = 800;
const VIDEO_HEIGHT = 600;

Tern tern;

void main() {
  
  Sounds.loadSound('ding');
  Sounds.loadSound('ping');
  
  tern = new Tern();
}


class Tern {
  
  CanvasRenderingContext2D ctx;
  TangibleCompiler compiler;
  VideoElement video = null;
  Timer timer;
  MediaStream stream;
  Program program;
  
  /* Communicates to the NXT robot through a websocket (via Java) */
  WebSocket socket;


  
  Tern() {
    CanvasElement canvas = querySelector("#main-canvas");
    ctx = canvas.getContext("2d");
    compiler = new TangibleCompiler();
    video = querySelector("#video-stream");
    video.autoplay = true;
    video.onPlay.listen((e) {
      setHtmlOpacity('toolbar', 0.0);
      program = null;
      //ctx.drawImage(video, 0, 0);
      timer = new Timer.periodic(const Duration(milliseconds : 30), refreshCanvas);
    });

    // start the websocket connection
    connectToRobot();
    
    // bind button events
    bindClickEvent("robot-button", (event) { connectToRobot(); });
    bindClickEvent("camera-button", startStopVideo);
    bindClickEvent("play-button", (event) { playPause(); });
    bindClickEvent("restart-button", (event) { restart(); });
  }
  

  void connectToRobot() {
    socket = new WebSocket("ws://localhost:9003");
    socket.onOpen.listen((e) {
      print("Connected.");
      //sendRobotCommand("@nxt CONNECT");
    });
    socket.onMessage.listen((MessageEvent e) {
      if (e.data == "@dart DONE") {
        stepProgram();
      } else if (e.data == "@dart FOUND NXT") {
        setHtmlOpacity("robot-button", 1.0);
      } else {
        print(e.data);
      }
    });
  }

  
/**
 * Send a command to the NXT robot
 */
  bool sendRobotCommand(String command) {
    print(command);
    if (socket != null && socket.readyState == WebSocket.OPEN) {
      socket.send(command);
      return true;
    } else {
      return false;
    }
  }

  
/*
 * Start / stop the video stream
 */
  void startStopVideo(var event) {
    if (stream == null) {
      startVideo();
    } else {
      stopVideo();
    }
  }


/**
 * Start the video stream
 */
  void startVideo() {
    if (stream == null) {
      restart();
      var vconfig = {
        'mandatory' : {
          'minWidth' : VIDEO_WIDTH,
          'minHeight' : VIDEO_HEIGHT
        }
      };
      window.navigator.getUserMedia(audio : false, video : vconfig).then((var ms) {
        video.src = Url.createObjectUrl(ms);
        stream = ms;
      });
    }
  }


/**
 * Stop the video stream
 */
  void stopVideo() {
    if (stream != null) {
      if (timer != null) timer.cancel();
      video.pause();
      stream.stop();
      stream = null;
      setHtmlOpacity('scan-message', 0.0);
    }
  }


/*
 * Called 30 frames a second while the camera is on
 */
  void refreshCanvas(Timer timer) {

    // draw a frame from the video stream onto the canvas
    ctx.drawImage(video, 0, 0);
    
    // grab a bitmap from the canvas
    ImageData id = ctx.getImageData(0, 0, VIDEO_WIDTH, VIDEO_HEIGHT);
    program = compiler.compile(id);
    program.draw(ctx);
    
    // STATUS: Looking for stickers...
    if (program.isEmpty) {
      setHtmlText('scan-message', 'Looking for stickers...');
      setHtmlOpacity('scan-message', 1.0);
    }
    
    // STATUS: Looking for BEGIN...
    else if (!program.hasStartStatement) {
      setHtmlText('scan-message', 'Looking for BEGIN sticker...');
      setHtmlOpacity('scan-message', 1.0);
    }
    
    // STATUS: Looking for END...
    else if (!program.hasEndStatement) {
      setHtmlText('scan-message', 'Looking for END sticker...');
      setHtmlOpacity('scan-message', 1.0);
    }
    
    // STATUS: Can't connect ...
    else if (!program.isComplete) {
      setHtmlText('scan-message', "Can't connect BEGIN sticker to END sticker...");
      setHtmlOpacity('scan-message', 1.0);
    }
    
    // STATUS:  Found program!
    else {
      Sounds.playSound('ping');
      setHtmlText('scan-message', "Found program!");
      setHtmlOpacity('scan-message', 0.0);
      setHtmlOpacity('toolbar', 1.0);
      stopVideo();
      program.restart();
      Rectangle bounds = program.getBounds;
      id = ctx.getImageData(bounds.left, bounds.top, bounds.width, bounds.height);
      ctx.fillStyle = "rgba(255, 255, 255, 0.5)";
      ctx.fillRect(0, 0, VIDEO_WIDTH, VIDEO_HEIGHT);
      ctx.putImageData(id, bounds.left, bounds.top);    
    }
  }


  void restart() {
    setBackgroundImage('play-button', 'images/play.png');
    if (program != null && program.isComplete) {
      program.restart();
      timer.cancel();
    }
  }
  
  
  void play() {
    setBackgroundImage('play-button', 'images/pause.png');
    if (program != null && program.isComplete) {
      program.play();
      stepProgram();
      //timer = new Timer.periodic(const Duration(milliseconds : 100), animate);
    }
  }
  
  
  void pause() {
    setBackgroundImage('play-button', 'images/play.png');
    if (program != null && program.isComplete) {
      program.pause();
      //timer.cancel();
    }
  }
  
  
  void playPause() {
    if (program != null && program.isComplete) {
      if (program.isPlaying) {
        pause();
      } else {
        play();
      }
    }
  }

  
  //void animate(Timer timer) {
  void stepProgram() {
    if (program == null) return;
    if (program.isDone) {
      restart();
    }
    else if (program.isPlaying) {
      if (!sendRobotCommand(program.message)) {
        new Timer(const Duration(milliseconds : 1600), () => stepProgram());
      }
      
      int iw = program.block.width;
      int ih = program.block.height;
      ctx.drawImageScaled(program.block,  25, 25, 150, 150);
      program.step();
    }
    else {
      restart();
    }
  }
}
  
  
