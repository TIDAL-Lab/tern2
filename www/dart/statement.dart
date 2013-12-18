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
 * A base class for all tangible language statements. A statement is
 * any element that can be connected in a program's flow-of-control.
 * A statement must have at least one socket or one connector (most
 * have both a socket and a connector). Statements have no implicit
 * data type and carry no return value.
 */
class Statement {
   
  static int NEST = 0;


  /** TopCode for this statement */
  TopCode top = null;
   
  /** Name of the statement */
  String name = '';

  /** Image source */
  String image = null;
   
  /** Is this statement a start statement */
  bool start = false;
  
  /** Is this statement an end statement */
  bool end = false;
  
  /** Duration that this statement should be displayed on the screen */
  int duration = 25;
  
  /** Parameter value */
  var value = null;

  /** List of connectors (ingoing, outgoing, and params) for this statement */
  List<Connector> connectors;
   
   
  Statement(this.top) {
    connectors = new List<Connector>();
  }
  
    
  factory Statement.fromJSON(var d) {
    TopCode top = new TopCode();
    top.code = d['code'];
    Statement s = null;
    if (d.containsKey('class')) {
      if (d['class'] == 'RepeatStatement') {
        s = new RepeatStatement(top);
      }
      else if (d['class'] == 'EndRepeatStatement') {
        s = new EndRepeatStatement(top);
      }
    }
    
    if (s == null) {
      s = new Statement(top);
    }

    s.name = d['name'];
    s.image = d['image'];
    s.value = d['value'];
    if (d.containsKey('start')) s.start = true;
    if (d.containsKey('end')) s.end = true;
    if (d.containsKey('duration')) s.duration = d['duration'];
    if (d.containsKey('socket')) {
      Connector c = new Connector(s, TYPE_IN, 'prev', 0.0, 0.0);
      if (d['socket'] is Map && d['socket'].containsKey('dx') && d['socket'].containsKey('dy')) {
        c.dx = d['socket']['dx'].toDouble();
        c.dy = d['socket']['dy'].toDouble();
      }
      s.addConnector(c);
    }
    
    if (d.containsKey('plug')) {
      Connector c = new Connector(s, TYPE_OUT, 'next', 3.5, 0.0);
      if (d['plug'] is Map && d['plug'].containsKey('dx') && d['plug'].containsKey('dy')) {
        c.dx = d['plug']['dx'].toDouble();
        c.dy = d['plug']['dy'].toDouble();
      }
      s.addConnector(c);
    }
    
    if (d.containsKey('param')) {
      Connector c = new Connector(s, TYPE_PARAM, 'param', 0.0, -3.2);
      if (d['param'] is Map && d['param'].containsKey('dx') && d['param'].containsKey('dy')) {
        c.dx = d['param']['dx'].toDouble();
        c.dy = d['param']['dy'].toDouble();
      }
      s.addConnector(c);
    }
    return s;
  }
  
  
/**
 * Clone the current statement
 */
  Statement clone(TopCode top) {
    Statement s = new Statement(top);
    _copy(s);
    return s;
  }
  
  
  void _copy(Statement other) {
    other.name = this.name;
    other.image = this.image;
    other.value = this.value;
    other.start = this.start;
    other.end = this.end;
    other.duration = this.duration;
    for (Connector c in connectors) {
      other.addConnector(c.clone(other));
    }
  }
  
  
  String getName() {
    return name;
  }


  void addConnector(Connector con) {
    connectors.add(con);
  }
   
   
  List<Connector> getConnectors() {
    return connectors;
  }
  
  
  bool get hasTopCode { return top != null; }
   

  bool hasConnection(String name) {
    for (Connector c in connectors) {
      if (name == c.name) {
        return c.hasConnection;
      }
    }
    return false;
  }
  
  
  bool get hasIncomingConnection {
    for (Connector c in connectors) {
      if (c.isIncoming && c.hasConnection) {
        return true;
      }
    }
    return false;
  }
  
  
  bool get hasParameter {
    for (Connector c in connectors) {
      if (c.isParameter && c.hasConnection) {
        return true;
      }
    }
    return false;
  }
   
   
  Statement getConnection(String name) {
    for (Connector c in connectors) {
      if (name == c.name) {
        return c.getConnection();
      }
    }
    return null;
  }
  
  
  Statement getNextStatement() {
    for (Connector c in connectors) {
      if (c.isOutgoing && c.hasConnection) {
        return c.getConnection();
      }
    }
    return null;
  }
  
  
  Statement getPrevStatement() {
    for (Connector c in connectors) {
      if (c.isIncoming && c.hasConnection) {
        return c.getConnection();
      }
    }
    return null;
  }
  
  
  Statement getParameter() {
    for (Connector c in connectors) {
      if (c.isParameter && c.hasConnection) {
        return c.getConnection();
      }
    }
    return null;
  }
   
   
  bool get isCompleteProgram {
    if (end) {
      return true;
    } else {
      for (Connector c in connectors) {
        if (c.isOutgoing && c.hasConnection) {
          if (c.getConnection().isCompleteProgram) {
            return true;
          }
        }
      }
    }
    return false;
  }


  bool get isStartStatement => start;
  
  bool get isEndStatement => end;
   
   
  void connect(Statement other) {
    for (Connector plug in connectors) {
      if (plug.isOutgoing || plug.isParameter) {
        for (Connector socket in other.connectors) {
          if (socket.isIncoming) {
            if (socket.overlaps(plug)) {
              plug.setConnection(other);
              socket.setConnection(this);
            }
          }
        }
      }
    }
  }
  
  
  void draw(CanvasRenderingContext2D ctx) {
    if (hasTopCode) {
      top.draw(ctx, 1.3);
    }
  }
  
  
  void drawProgram(CanvasRenderingContext2D ctx) {
      /*
    if (hasTopCode) {
      double r = top.radius * 1.5;
      ctx.fillStyle = 'green';
      ctx.beginPath();
      ctx.arc(top.x, top.y, r, 0, PI * 2, true);
      ctx.fill();
      top.draw(ctx, 1.3);
    }
    
    for (Connector c in connectors) {

      if (c.isOutgoing && c.hasConnection) {
        c.getConnection().drawProgram(ctx);
      }
      else if (c.isParameter && c.hasConnection) {
        c.getConnection().drawProgram(ctx);
      }
    }
      */
  }
}


class RepeatStatement extends Statement {
  
  int count = 0;
  
  RepeatStatement(TopCode top) : super(top);
  
  
  Statement clone(TopCode top) {
    Statement s = new RepeatStatement(top);
    _copy(s);
    return s;
  }
  
  
  String getName() {
    Statement param = getParameter();
    
    if (param == null) {
      return "Repeat Forever";
    }
    else if (param.value == null) {
      return "Repeat";
    }
    else if (param.value is int) {
      return "Repeat ${param.value} Times";
    }
    else {
      return "Repeat Until ${param.value}";
    }
  }
  
  
  Statement getNextStatement() {
    Statement param = getParameter();
    
    if (param != null && param.value != null && param.value is int) {
      if (count <= 0) {
        count = param.value - 1;
      } else {
        count--;
      }
    }
    return super.getNextStatement();
  }

  
  bool doLoop() {
    Statement param = getParameter();
    if (param == null || param.value == null) {
      return true;
    } else if (count <= 0) {
      return false;
    } else {
      return true;
    }
  }
}


class EndRepeatStatement extends Statement {
  
  EndRepeatStatement(TopCode top) : super(top);
  
  
  Statement clone(TopCode top) {
    Statement s = new EndRepeatStatement(top);
    _copy(s);
    return s;
  }
  
  
  Statement getNextStatement() {
    Statement prev = this;
    while (prev != null) {
      prev = prev.getPrevStatement();
      if (prev == null || prev.isStartStatement) {
        return super.getNextStatement();
      } else if (prev is RepeatStatement) {
        RepeatStatement br = prev as RepeatStatement;
        if (br.doLoop()) {
          return br;
        } else {
          return super.getNextStatement();
        }
      }
    }
  }
}
