/*
 * Tern Tangible Programming Language
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
part of StickerBook;


/**
 * A program is simply a list of instructions created by the compiler.
 * Programs may be translated into some other text-based language or
 * interpreted by a virtual machine.
 */
class Program {

	
	/** List of statements recognized in an image */
	List<Statement> statements;
	
	/** Rectangle that frames a program in the image */
	double xmin, ymin, xmax, ymax;
  
  /** Currently executing statement */
  Statement curr = null;
  
  /** Is the program currently paused */
  bool paused = true;
  
  //int timeout = 0;
  String message = "";
  ImageElement block;
   
	Program() {
    xmin       = 1600.0;
    ymin       = 1200.0;
    xmax       = 0.0;
    ymax       = 0.0;
    statements = new List<Statement>();
    block = new ImageElement();
	}
   
   
  void addStatement(Statement s) {
    statements.add(s);
    if (s.hasTopCode) {
      double x0 = s.top.x - s.top.radius * 4;
      double y0 = s.top.y - s.top.radius * 4;
      double x1 = s.top.x + s.top.radius * 4;
      double y1 = s.top.y + s.top.radius * 4;
      xmax = (x1 > xmax)? x1 : xmax;
      ymax = (y1 > ymax)? y1 : ymax;
      xmin = (x0 < xmin)? x0 : xmin;
      ymin = (y0 < ymin)? y0 : ymin;
    }
  }


  bool get isEmpty { return (statements.isEmpty); }
  
  
  Statement getStartStatement() {
    for (Statement s in statements) {
      if (s.isStartStatement) {
        return s;
      }
    }
    return null;
  }


  bool get hasStartStatement {
    for (Statement s in statements) {
      if (s.isStartStatement) {
        return true;
      }
    }
    return false;
  }
  
  
  bool get hasEndStatement {
    for (Statement s in statements) {
      if (s.isEndStatement) {
        return true;
      }
    }
    return false;
  }
  
  
  bool get isComplete {
    for (Statement s in statements) {
      if (s.isStartStatement) {
        if (s.isCompleteProgram) {
          return true;
        }
      }
    }
    return false;
  }
  
  
  void draw(CanvasRenderingContext2D ctx) {

    for (Statement s in statements) {
      s.draw(ctx);
    }
  }
  
  
  void step() {
    if (isPlaying) {
      curr = curr.getNextStatement();
      if (curr != null) {
        message = curr.image;
        block.src = "images/block-${curr.image}.png";
      }
    }
  /*
      if (timeout > 0) {
        timeout--;
      } else {
        curr = curr.getNextStatement();
        if (curr != null) {
          timeout = curr.duration;
          message = curr.getName();
          block.src = "images/block-${curr.image}.png";
          tern.sendRobotCommand(curr.image);
        }
      }
    }
  */
  }
  
  
  void play() {
    if (curr != null) {
      paused = false;
    }
  }
  
  
  void pause() {
    paused = true;
  }
  
  
  void restart() {
    curr = getStartStatement();
    paused = true;
    //timeout = 20;
    if (curr != null) {
      message = curr.name;
      block.src = "images/block-${curr.image}.png";
    }
  }
  
  
  bool get isPlaying => curr != null && !paused;
  
  
  bool get isDone => curr == null;
  

/**
 * Returns a bounding box around a program in a bitmap image.
 */
  Rectangle get getBounds {
    return new Rectangle(xmin - 20, ymin - 30, (xmax - xmin) + 40, (ymax - ymin) + 40);
  }
}
