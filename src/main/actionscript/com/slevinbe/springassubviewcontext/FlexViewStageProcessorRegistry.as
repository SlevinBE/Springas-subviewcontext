package com.slevinbe.springassubviewcontext {
	import flash.display.DisplayObject;
	import flash.events.Event;

	import mx.core.UIComponent;

	import org.as3commons.logging.ILogger;
	import org.as3commons.logging.getClassLogger;
	import org.springextensions.actionscript.stage.FlexStageProcessorRegistry;
	import org.springextensions.actionscript.utils.ApplicationUtils;

	public class FlexViewStageProcessorRegistry extends FlexStageProcessorRegistry {

		private static const CANNOT_INSTANTIATE_DIRECTLY:String = "Cannot instantiate FlexViewStageProcessorRegistry directly, invoke getInstance() instead";

		private static var _instance:FlexViewStageProcessorRegistry;
		private static var LOGGER:ILogger = getClassLogger(FlexViewStageProcessorRegistry);

		public var rootComponent:UIComponent;

		public function FlexViewStageProcessorRegistry() {
			super(null);
		}

		/**
		 * @inheritDoc
		 */
		override public function processStage(startComponent:DisplayObject = null):void {
			if (!startComponent) {
				startComponent = DisplayObject(rootComponent);
			}

			//add an "added" event listener to components that are being processed
			//which aren't in the same display hierarchy as the rootcomponent, like popups etc.
			if(startComponent != rootComponent && startComponent is UIComponent
					&& !isAncestorOfRootComponent(startComponent as UIComponent)) {
				startComponent.addEventListener(Event.ADDED_TO_STAGE, view_added_handler, true);
				startComponent.addEventListener(Event.REMOVED_FROM_STAGE, view_removed_handler);
			}

			LOGGER.debug(STAGE_PROCESSING_STARTED, startComponent);
			processDisplayObjectRecursively(startComponent);
			LOGGER.debug(STAGE_PROCESSING_COMPLETED);
		}

		/**
		 * If <code>enabled</code> is <code>true</code> and the displayObject is a (indirect) child
		 * of the rootComponent, this event handler passes the <code>event.target</code> to the
		 * <code>processStageComponent()</code> method.
		 * @param event The <code>Event.ADDED_TO_STAGE</code> instance.
		 */
		override protected function added_handler(event:Event):void {
			if (enabled) {
				var displayObject:UIComponent = event.target as UIComponent;
				if (isAncestorOfRootComponent(displayObject)) {
					processDisplayObjectRecursively(displayObject);
				}
			}
		}

		private function view_added_handler(event:Event):void {
			if (enabled) {
				var displayObject:UIComponent = event.target as UIComponent;
				processDisplayObjectRecursively(displayObject);
			}
		}

		private function view_removed_handler(event:Event):void {
			event.currentTarget.removeEventListener(Event.ADDED_TO_STAGE, view_added_handler);
			event.currentTarget.removeEventListener(Event.REMOVED_FROM_STAGE, view_removed_handler);
		}

		/**
		 * Retrieves the root component of the given UIComponent. The root will either be the Application, Module or (native) Window
		 * the component lives in.
		 */
		override protected function getRoot(component:UIComponent):Object {
			return rootComponent;
		}

		override protected function initFlexStageProcessorRegistry(singletonToken:Object):void {
			init();
		}

		private function isAncestorOfRootComponent(displayObject:UIComponent):Boolean {
			if (displayObject == null || (displayObject == ApplicationUtils.application && displayObject != rootComponent)) {
				return false;
			}

			if (displayObject == rootComponent) {
				return true;
			}

			return isAncestorOfRootComponent(displayObject.parentDocument as UIComponent);
		}
	}
}
