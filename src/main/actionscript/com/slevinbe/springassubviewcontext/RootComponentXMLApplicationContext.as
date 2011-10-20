package com.slevinbe.springassubviewcontext {
	import flash.events.Event;

	import mx.core.UIComponent;
	import mx.modules.Module;

	import org.springextensions.actionscript.context.support.FlexXMLApplicationContext;
	import org.springextensions.actionscript.ioc.autowire.DefaultFlexAutowireProcessor;
	import org.springextensions.actionscript.ioc.factory.config.LoggingTargetObjectPostProcessor;
	import org.springextensions.actionscript.ioc.factory.support.referenceresolvers.ArrayCollectionReferenceResolver;
	import org.springextensions.actionscript.ioc.factory.xml.parser.support.FlexXMLObjectDefinitionsParser;
	import org.springextensions.actionscript.module.OwnerModuleObjectPostProcessor;
	import org.springextensions.actionscript.utils.ApplicationUtils;

	/**
	 * This application context class allows to specify any component
	 * which will then be processed automatically by the stage processor
	 * to resolve the injections (including the tree of subcomponents beneath it).
	 */
	public class RootComponentXMLApplicationContext extends FlexXMLApplicationContext implements IRootComponentAware {

		private var _rootComponent:UIComponent;

		public function RootComponentXMLApplicationContext(rootComponent:UIComponent, source:* = null) {
			_rootComponent = rootComponent;
			super(source);
		}

		public function get rootComponent():UIComponent {
			return _rootComponent;
		}

		public function set rootComponent(value:UIComponent):void {
			if (value !== _rootComponent) {
				if (_rootComponent != null) {
					stageProcessorRegistry.unregisterContext(_rootComponent, this);
				}
				_rootComponent = value;

				if (_rootComponent) {
					stageProcessorRegistry.registerContext(_rootComponent, this);
				}
				if ((stageProcessorRegistry.enabled) && (_rootComponent) && (!configurationCompleted)) {
					stageProcessorRegistry.enabled = false;
				}
			}
		}

		override protected function preinitFlexXMLApplicationContext():void {
			configurationCompleted = false;
			parser = new FlexXMLObjectDefinitionsParser(this);
			autowireProcessor = new DefaultFlexAutowireProcessor(this);

			var processorRegistry:FlexViewStageProcessorRegistry = new FlexViewStageProcessorRegistry();
			processorRegistry.rootComponent = rootComponent;
			stageProcessorRegistry = processorRegistry;

		}

		/**
		 * Initializes the <code>FlexXMLApplicationContext</code> instance.
		 */
		override protected function initFlexXMLApplicationContext(ownerModule:Module):void {
			this.ownerModule = ownerModule;

			// add a factory postprocessor to add stageprocessors
			addObjectFactoryPostProcessor(new RootComponentProcessorFactoryPostProcessor());

			// add flex specific reference resolvers
			addReferenceResolver(new ArrayCollectionReferenceResolver(this));

			// add flex specific object post processors
			addObjectPostProcessor(new LoggingTargetObjectPostProcessor());
			addObjectPostProcessor(new OwnerModuleObjectPostProcessor());
		}

		/**
		 * <code>Event.COMPLETE</code> event handler added in context constructor.
		 * Attempts to wire all the components that are already on the stage cache.
		 * Assigns the systemManager property with the current application's systemManager
		 * and adds the stageWireObjectHandler() method as an Event.ADDED listener on the systemManager.
		 * @param event The specified <code>Event.COMPLETE</code> event
		 */
		override protected function completeHandler(event:Event):void {
			configurationCompleted = true;
			removeEventListener(Event.COMPLETE, completeHandler);

			if (!_rootComponent) {
				_rootComponent = ApplicationUtils.application as UIComponent;
			}

			stageProcessorRegistry.registerContext(_rootComponent, this);

			if (stageProcessorRegistry.initialized) {
				stageProcessorRegistry.enabled = true;
				if (_rootComponent) {
					stageProcessorRegistry.processStage(_rootComponent);
				}
			} else {
				stageProcessorRegistry.initialize();
			}
		}

		override public function dispose():void {
			if (!isDisposed) {
				if (_rootComponent != null) {
					skipDispose = true;
					_rootComponent = null;
				}
				super.dispose();
			}
		}

	}
}
