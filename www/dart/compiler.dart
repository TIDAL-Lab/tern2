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


/**
 * Compiles a tangible program.
 *
 * @author Michael Horn
 */
class TangibleCompiler {
   
  /** Scans image bitmap files for topcodes */
  Scanner scanner;
  
  /** Used to generate new statements from top codes */
  StatementFactory generator;
   
   
  TangibleCompiler() {
    scanner    = new Scanner();
    generator  = new StatementFactory(STATEMENTS);
  }
   

/**
 * Tangible compile function: generate a program from a bitmap image
 */
  Program compile(ImageData image, CanvasRenderingContext2D ctx) {
      
    Program program = new Program();

    //-----------------------------------------------------------
    // 1. Create a list of topcodes from the bitmap image
    //-----------------------------------------------------------
    List<TopCode> spots = scanner.scan(image, ctx);

    //-----------------------------------------------------------
    // 2. Convert topcodes to statements
    //-----------------------------------------------------------
    for (TopCode top in spots) {
      Statement s = generator.createStatement(top);
      if (s != null) {
        program.addStatement(s);
      }
    }


    //-----------------------------------------------------------
    // 3. Connect chains of statements together
    //-----------------------------------------------------------
    for (Statement a in program.statements) {
      for (Statement b in program.statements) {
        if (a != b) {
          a.connect(b);
        }
      }
    }
    return program;
  }
}