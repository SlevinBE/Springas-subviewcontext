package com.slevinbe.springassubviewcontext {
	import flash.display.DisplayObject;

	public interface IViewRegistrator {

		/**
		 * Registers the view so that actions can be performed on it.
		 * @param view
		 */
		function registerView(view:DisplayObject):void;
	}
}
