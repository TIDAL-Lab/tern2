/*
 * StickerBook
 *
 * Michael S. Horn
 * Northwestern University
 * michael-horn@northwestern.edu
 * Copyright 2013, Michael S. Horn
 */
part of StickerBook;


/**
 * Detects whether or not this is an iPad based on the user-agent string
 */
bool isIPad() {
  return window.navigator.userAgent.contains("iPad");
}

/**
 * Binds a click event to a button
 */
void bindClickEvent(String id, Function callback) {
  Element el = querySelector("#${id}");
  if (el != null) {
    if (isIPad()) {
      //el.onTouchEnd.listen(callback);    
    } else {
      el.onMouseUp.listen(callback);
    }
  }
}

/**
 * Adds a class to a DOM element
 */
void addHtmlClass(String id, String cls) {
  Element el = querySelector("#${id}");
  if (el != null) {
    el.classes.add(cls);
  }
}


/**
 * Removes a class from a DOM element
 */
void removeHtmlClass(String id, String cls) {
  Element el = querySelector("#${id}");
  if (el != null) {
    el.classes.remove(cls);
  }
}


/**
 * Sets the inner HTML for the given DOM element 
 */
void setHtmlText(String id, String text) {
  Element el = querySelector("#${id}");
  if (el != null) {
    el.innerHtml = text;
  }
}


/*
 * Sets the visibility state for the given DOM element
 */
void setHtmlVisibility(String id, bool visible) {
  Element el = querySelector("#${id}");
  if (el != null) {
    el.style.visibility = visible ? "visible" : "hidden";
  }
}


/*
 * Sets the opacity state for the given DOM element
 */
void setHtmlOpacity(String id, double opacity) {
  Element el = querySelector("#${id}");
  if (el != null) {
    el.style.opacity = "${opacity}";
  }
}


/*
 * Sets teh background image for the given DOM element
 */
void setBackgroundImage(String id, String src) {
  Element el = querySelector("#${id}");
  if (el != null) {
    el.style.backgroundImage = "url('${src}')";
  }
}

