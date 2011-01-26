package de.patrickheinzelmann.components.spark
{
	import de.patrickheinzelmann.components.spark.skins.VSliderSkin;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.events.ResizeEvent;
	
	import spark.components.Button;
	import spark.components.HSlider;
	
	/**
	 *  The color for the slider track when it is selected.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	[Style(name="trackHighlightColor", type="Class", inherit="no")]
	
	/**
	 *  Specifies whether to enable track highlighting between thumbs
	 *  (or a single thumb and the beginning of the track).
	 *
	 *  @default false
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	[Style(name="showTrackHighlight", type="Boolean", inherit="no")]
	
	public class VSlider extends spark.components.VSlider
	{
		[SkinPart(required="false")]
		public var trackHighLight:Button;
		
		[Bindable]
		private var _trackHighlightColor:uint; 
		
		[Bindable]
		private var _showTrackHighlight:Boolean = true;
		
		/**
		 *  @private
		 */
		private var trackHighlightChanged:Boolean = true;
		
		public function VSlider()
		{
			super();
			setStyle("skinClass", VSliderSkin);
		}
		
		/**
		 *  @private
		 */
		override protected function updateSkinDisplayList():void
		{
			super.updateSkinDisplayList();
			if (!thumb || !track || !trackHighLight)
				return;
			
			var thumbRange:Number = track.getLayoutBoundsHeight() - thumb.getLayoutBoundsHeight();
			var range:Number = maximum - minimum;
			
			// calculate new thumb position.
			var thumbPosTrackY:Number = (range > 0) ? thumbRange - (((pendingValue - minimum) / range) * thumbRange) : 0;
			
			// convert to parent's coordinates.
			var thumbPos:Point = track.localToGlobal(new Point(0, thumbPosTrackY));
			var thumbPosParentY:Number = thumb.parent.globalToLocal(thumbPos).y+thumb.getLayoutBoundsHeight()/2;
			
			trackHighLight.setLayoutBoundsPosition(trackHighLight.getLayoutBoundsX(), thumbPosParentY);
			trackHighLight.setLayoutBoundsSize( trackHighLight.getLayoutBoundsWidth(), track.getLayoutBoundsHeight()-thumbPosParentY);
		}
		
		/**
		 *  @private
		 *  Warning: the goal of the listeners added here (and removed below) is to 
		 *  give the TrackBase a change to fixup the thumb's size and position
		 *  after the skin's BasicLayout has run.   This particular implementation
		 *  is a hack and it begs a solution to the general problem of what we've
		 *  called "cooperative layout".   More about that here:
		 *  http://opensource.adobe.com/wiki/display/flexsdk/Cooperative+Subtree+Layout
		 */
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			if (instance == trackHighLight)
			{
				trackHighLight.focusEnabled = false;
				trackHighLight.addEventListener(ResizeEvent.RESIZE, trackHighLight_resizeHandler);

			}
		}
		
		/**
		 *  @private
		 */
		override protected function partRemoved(partName:String, instance:Object):void
		{
			super.partRemoved(partName, instance);
			
			if (instance == trackHighLight)
			{
				trackHighLight.removeEventListener(MouseEvent.MOUSE_DOWN, track_mouseDownHandler);
				trackHighLight.removeEventListener(ResizeEvent.RESIZE, trackHighLight_resizeHandler);
			}
		}
		
		/**
		 *  @private
		 */
		private function trackHighLight_resizeHandler(event:Event):void
		{
			updateSkinDisplayList();
		}
		
		/**
		 *  @private
		 */
		override public function styleChanged(styleProp:String):void
		{
			var anyStyle:Boolean = styleProp == null || styleProp == "styleName";
			
			super.styleChanged(styleProp);
			if (styleProp == "showTrackHighlight" || anyStyle)
			{
				trackHighlightChanged = true;
				invalidateProperties();
			}
			
			if (styleProp == "trackHighlightColor" || anyStyle)
			{
				/*				if (innerSlider && highlightTrack)
				{
				innerSlider.removeChild(DisplayObject(highlightTrack));
				highlightTrack = null;
				}*/
				trackHighlightChanged = true;
				invalidateProperties();
			}
			
			invalidateDisplayList();
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if (trackHighlightChanged)
			{
				trackHighlightChanged = false;
			}
		}
		
		public function set trackHighlightColor(color:uint):void
		{
			this._trackHighlightColor = color;
			this.invalidateProperties();
		}
		
		
		public function get trackHighlightColor():uint
		{
			return this._trackHighlightColor;
		}
		
		public function set showTrackHighlight(show:Boolean):void
		{
			this._showTrackHighlight = show;
			this.invalidateProperties();
		}
		
		public function get showTrackHighlight():Boolean
		{
			return this._showTrackHighlight;
		}
	}
}