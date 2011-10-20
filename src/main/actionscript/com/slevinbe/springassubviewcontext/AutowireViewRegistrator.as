package com.slevinbe.springassubviewcontext {
	import flash.display.DisplayObject;

	import org.springextensions.actionscript.context.IApplicationContext;
	import org.springextensions.actionscript.context.IApplicationContextAware;
	import org.springextensions.actionscript.context.support.XMLApplicationContext;

	/**
	 * View registrator which autowires views on registration.
	 */
	public class AutowireViewRegistrator implements IViewRegistrator, IApplicationContextAware {

		private var _applicationContext:XMLApplicationContext;

		public function AutowireViewRegistrator() {
		}

		public function registerView(view:DisplayObject):void {
			_applicationContext.stageProcessorRegistry.processStage(view);
		}

		public function get applicationContext():IApplicationContext {
			return _applicationContext;
		}

		public function set applicationContext(value:IApplicationContext):void {
			_applicationContext = XMLApplicationContext(value);
		}
	}
}
