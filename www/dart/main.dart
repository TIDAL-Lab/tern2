/*
 * Tern Tangible Programming Language
 * Copyright (c) 2016 Michael S. Horn
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
library tern2;

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


const VIDEO_WIDTH = 1920; // 1280; // 800
const VIDEO_HEIGHT = 1080; // 720; // 600

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
  /* Communicates with robot through a websocket (via Java) */
  WebSocket socket;  
  //MediaStream stream = null;
  Program program;
  

  
  Tern() {
    CanvasElement canvas = querySelector("#video-canvas");
    ctx = canvas.getContext("2d");
    compiler = new TangibleCompiler();
    video = querySelector("#video-stream");
    video.autoplay = true;
    video.onPlay.listen((e) {
      program = null;
      timer = new Timer.periodic(const Duration(milliseconds : 30), refreshCanvas);
    });

    // start the websocket connection
    connectToRobot();    

    // bind button events
    //bindClickEvent("camera-button", startStopVideo);

/*
    window.navigator.mediaDevices.enumerateDevices().then((var devices) {
      for (var d in devices) {
        print(d.label);
        print(d.groupId);
        print(d.deviceId);
        print(d.kind);
      }
    });
*/    
  }


void connectToRobot() {
  String server = "ws://localhost:9003";
  setHtmlText('scan-message', "Not connected to $server");
  socket = new WebSocket(server);
  socket.onOpen.listen((e) {
    setHtmlText('scan-message', "Connected to $server");
  });
  socket.onMessage.listen((MessageEvent e) {
    if (e.data == "@dart DONE") {
      //stepProgram();
    } 
    else if (e.data == "@dart SUCCESS") {
      setHtmlText('scan-message', "Program loaded on robot!");
      print("compile success");
      Sounds.playSound('ping');
    }
    else {
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
      socket.send("@compile $command");
      return true;
    } else {
      return false;
    }
  }


/**
 * Start / stop the video stream
 */
 /*
  void startStopVideo(var event) {
    if (stream == null) {
      startVideo();
    } else {
      stopVideo();
    }
  }
*/

/**
 * Start the video stream
 */
/* 
  void startVideo() {
    if (stream == null) {
      var config = {
        "audio" : false,
        "video" : {
          "deviceId" : "90271ce40730999d3556964354ca563fef8aca005d5b6cb8db5db1fcbb5b7600",
          "width" : { "exact" : 1280 },
          "height" : { "exact" : 720 }
        }
      };
      window.navigator.mediaDevices.getUserMedia(config).then((var ms) {
        video.width = 1280;
        video.height = 720;
        video.src = Url.createObjectUrl(ms);
        stream = ms;
      });
    }
  }
*/

/**
 * Stop the video stream
 */
  void stopVideo() {
    video.pause();
    if (timer != null) timer.cancel();
/*    
    if (stream != null) {
      if (timer != null) timer.cancel();
      video.pause();
      stream.getVideoTracks()[0].stop();
      stream = null;
      setHtmlOpacity('scan-message', 0.0);
    }
*/
  }

/*
 * Called 30 frames a second while the camera is on
 */
  void refreshCanvas(Timer timer) {

    if (video.className == "stopped") {
      timer.cancel();
      print("stopping scan");
      return;
    }

    // draw a frame from the video stream onto the canvas (flipped horizontally)
    ctx.save();
    {
      //ctx.translate(video.videoWidth, 0);
      //ctx.scale(-1, 1);
      ctx.drawImage(video, 0, 0);
    }
    ctx.restore();

    // grab a bitmap from the canvas
    ImageData id = ctx.getImageData(0, 0, video.videoWidth, video.videoHeight);
    program = compiler.compile(id, ctx);
    program.draw(ctx);
    
    // STATUS: Looking for stickers...
    if (program.isEmpty) {
      setHtmlText('scan-message', 'Looking for blocks...');
      setHtmlOpacity('scan-message', 1.0);
    }
    
    // STATUS: Looking for BEGIN...
    else if (!program.hasStartStatement) {
      setHtmlText('scan-message', 'Looking for BEGIN block...');
      setHtmlOpacity('scan-message', 1.0);
    }
    
    // STATUS: Looking for END...
    else if (!program.hasEndStatement) {
      setHtmlText('scan-message', 'Looking for END block...');
      setHtmlOpacity('scan-message', 1.0);
    }
    
    // STATUS: Can't connect ...
    else if (!program.isComplete) {
      setHtmlText('scan-message', "Can't connect BEGIN to END...");
      setHtmlOpacity('scan-message', 1.0);
    }
    
    // STATUS:  Found program!
    else {
      Sounds.playSound('ping');
      setHtmlText('scan-message', "Found program!");
      //setHtmlOpacity('scan-message', 0.0);
      //setHtmlOpacity('toolbar', 1.0);
      stopVideo();
      program.restart();
      sendRobotCommand(program.toString());
      print(program.toString());
      Rectangle bounds = program.getBounds;
      id = ctx.getImageData(bounds.left, bounds.top, bounds.width, bounds.height);
      ctx.fillStyle = "rgba(255, 255, 255, 0.5)";
      ctx.fillRect(0, 0, VIDEO_WIDTH, VIDEO_HEIGHT);
      ctx.putImageData(id, bounds.left, bounds.top);    
    }
  }
}
  
  
