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
part of tern2;


class StatementFactory {

  Map<int, Statement> statements;
  
  
  StatementFactory(var definitions) {
    statements = new Map<int, Statement>();
    for (var def in definitions) {
      Statement s = new Statement.fromJSON(def);
      statements[def['id']] = s;
    }
  }
  

/**
 * Called by the tangible compiler to generate new statements
 * from topcodes found in an image.
 */
  Statement createStatement(TopCode top) {
    if (statements.containsKey(top.code)) {
      return statements[top.code].clone(top);
    } else {
      return null;
    }
  }
}



var STATEMENTS = [
  
  // start
  {
    'id' : 569,
    'name' : 'Begin',
    'start' : true,
    'image' : 'begin',
    'plug' : true,
    'code' : 'void setup() {'
  },
  
  // end
  {
    'id' : 369,
    'name' : 'End',
    'end' : true,
    'image' : 'end',
    'socket' : true,
    'code' : '}'
  },
  
  // jump
  {
    'id' : 307,
    'name' : 'Jump',
    'image' : 'jump',
    'socket' : true,
    'plug' : true,
    'code' : 'jump();'
  },
  
  // backward
  {
    'id' : 185,
    'name' : 'Backward',
    'image' : 'backward',
    'socket' : true,
    'plug' : true,
    'code' : 'backward();'
  },
  
  // forward
  {
    'id' : 405,
    'name' : 'Forward',
    'image' : 'forward',
    'socket' : true,
    'plug' : true,
    'code' : 'forward();'
  },
  
  // shake
  {
    'id' : 557,
    'name' : 'Shake',
    'image' : 'shake',
    'socket' : true,
    'plug' : true,
    'code' : 'shake();'
  },
  
  // beep
  {
    'id' : 661,
    'name' : 'Beep',
    'image' : 'beep',
    'socket' : true,
    'plug' : true,
    'code' : 'beep();'
  },
  
  // sing
  {
    'id' : 397,
    'name' : 'Sing',
    'image' : 'sing',
    'socket' : true,
    'plug' : true,
    'code' : 'sing();'
  },
  
  // left
  {
    'id' : 1189,
    'name' : 'Turn Left',
    'image' : 'left',
    'socket' : true,
    'plug' : true,
    'code' : 'left();'
  },
  
  // right
  {
    'id' : 61,
    'name' : 'Turn Right',
    'image' : 'right',
    'socket' : true,
    'plug' : true,
    'code' : 'right();'
  },
  
  // spin
  {
    'id' : 331,
    'name' : 'Spin',
    'image' : 'spin',
    'socket' : true,
    'plug' : true,
    'code' : 'spin();'
  },
  
  // wiggle
  {
    'id' : 155,
    'name' : 'Wiggle',
    'image' : 'wiggle',
    'socket' : true,
    'plug' : true,
    'code' : 'wiggle();'
  },
  
  // tap sensor
  {
    'id' : 491,
    'name' : 'Tap Sensor',
    'socket' : { },
    'plug' : { 'dx' : 3, 'dy' : 0 }
  },
  
  // begin repeat
  {
    'id' : 171,
    'name' : 'Begin Repeat',
    'image' : 'repeat',
    'class' : 'RepeatStatement',
    'duration' : 5,
    'socket' : true,
    'plug' : true,
    'param' : { 'dx' : 0, 'dy' : -3 },
    'code' : 'while (1) {'
  },
  
  // end repeat
  {
    'id' : 179,
    'name' : 'End Repeat',
    'image' : 'end-repeat',
    'class' : 'EndRepeatStatement',
    'duration' : 5,
    'socket' : true,
    'plug' : true,
    'code' : '}'
  },
  
  // wait for
  {
    'id' : 611,
    'name' : 'Wait For',
    'image' : 'wait',
    'socket' : true,
    'plug' : true
  },
  
  // number 2
  {
    'id' : 327,
    'name' : '2',
    'value' : 2,
    'socket' : true
  },
  
  // number 3
  {
    'id' : 205,
    'name' : '3',
    'value' : 3,
    'socket' : true
  },
  
  // number 4
  {
    'id' : 103,
    'name' : '4',
    'value' : 4,
    'socket' : true
  }  
];

	
