/*
 * @(#) Connector.java
 * 
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
part of tern2;


/**
 * Represents an ingoing or outgoing connection from one statement
 * (the owner) to another.
 *
 * @author Michael Horn
 */
const TYPE_IN    = 0;   // incoming connection
const TYPE_OUT   = 1;   // outgoing connection
const TYPE_PARAM = 2;   // parameter connection
   
class Connector {

  int type;
  String name;
  double dx, dy;
  Statement parent;
  Statement other = null;
   
   
  Connector(this.parent, this.type, this.name, this.dx, this.dy);

   
  Connector clone(Statement parent) {
    return new Connector(parent, type, name, dx, dy);
  }
   
  bool get isOutgoing {
    return type == TYPE_OUT;
  }
   
  bool get isIncoming {
    return type == TYPE_IN;
  }
   
  bool get isParameter {
    return type == TYPE_PARAM;
  }
   
  void setDelta(double dx, double dy) {
    this.dx = dx;
    this.dy = dy;
  }
   
  double getTargetX() {
    TopCode top = parent.top;
    double d = top.diameter;
    double o = top.orientation;
    double x = top.x;
    return (x + dx * d * cos(o) - dy * d * sin(o));
  }
   
  double getTargetY() {
    TopCode top = parent.top;
    double d = top.diameter;
    double o = top.orientation;
    double y = top.y;
    return (y + dx * d * sin(o) + dy * d * cos(o));
  }
   
  bool overlaps(Connector other) {
    double tx = (other.getTargetX() - getTargetX());
    double ty = (other.getTargetY() - getTargetY());
    double r = parent.top.diameter * 0.8;
    return ((tx * tx + ty * ty) <= (r * r));
  }
   
  Statement getConnection() {
    return other;
  }
   
  void setConnection(Statement s) {
    other = s;
  }
   
  bool get hasConnection {
    return other != null;
  }
  
  
  void draw(CanvasRenderingContext2D ctx) {
    if (isOutgoing || isParameter) {
      if (parent != null && parent.hasTopCode) {
        TopCode top = parent.top;
        ctx.strokeStyle = 'green';
        ctx.lineWidth = top.unit;
        ctx.lineCap = 'round';
        ctx.beginPath();
        ctx.moveTo(top.x, top.y);
        ctx.lineTo(getTargetX(), getTargetY());
        ctx.stroke();
      }
    }
  }
  
}
