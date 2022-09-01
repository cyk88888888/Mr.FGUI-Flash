package fairygui
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	
	import fairygui.display.MovieClip;
	import fairygui.display.UISprite;
	import fairygui.utils.ToolSet;
	
	public class GLoader extends GObject
	{
		private var _url:String;
		private var _align:int;
		private var _verticalAlign:int;
		private var _autoSize:Boolean;
		private var _fill:int;
		private var _shrinkOnly:Boolean;
		private var _showErrorSign:Boolean;
		private var _playing:Boolean;
		private var _frame:int;
		private var _color:uint;
		
		private var _contentItem:PackageItem;
		private var _contentSourceWidth:int;
		private var _contentSourceHeight:int;
		private var _contentWidth:int;
		private var _contentHeight:int;
		
		private var _container:Sprite;
		private var _content:DisplayObject;
		private var _errorSign:GObject;
		private var _content2:GComponent;
		
		private var _updatingLayout:Boolean;
		
		private var _loading:int;
		private var _externalLoader:Loader;
		private var _initExternalURLBeforeLoadSuccess:String;
		
		private static var _errorSignPool:GObjectPool = new GObjectPool();
		
		public function GLoader()
		{
			_playing = true;
			_url = "";
			_align = AlignType.Left;
			_verticalAlign = VertAlignType.Top;
			_showErrorSign = true;
			_color = 0xFFFFFF;
		}
		
		override protected function createDisplayObject():void
		{
			_container = new UISprite(this);
			setDisplayObject(_container);
		}
		
		public override function dispose():void
		{
			if(_contentItem!=null)
			{
				if(_loading==1)
					_contentItem.owner.removeItemCallback(_contentItem, __imageLoaded);
				else if(_loading==2)
					_contentItem.owner.removeItemCallback(_contentItem, __movieClipLoaded);
			}
			else
			{
				//external
				if(_content!=null)
					freeExternal(_content);
			}
			if(_content2!=null)
				_content2.dispose();

			super.dispose();
		}

		final public function get url():String
		{
			return _url;
		}

		public function set url(value:String):void
		{
			if(_url==value)
				return;
			
			_url = value;
			loadContent();
			updateGear(7);
		}
		
		override public function get icon():String
		{
			return _url;
		}
		
		override public function set icon(value:String):void
		{
			this.url = value;
		}
		
		final public function get align():int
		{
			return _align;
		}
		
		public function set align(value:int):void
		{
			if(_align!=value)
			{
				_align = value;
				updateLayout();
			}
		}
		
		final public function get verticalAlign():int
		{
			return _verticalAlign;
		}
		
		public function set verticalAlign(value:int):void
		{
			if(_verticalAlign!=value)
			{
				_verticalAlign = value;
				updateLayout();
			}
		}
		
		final public function get fill():int
		{
			return _fill;
		}
		
		public function set fill(value:int):void
		{
			if(_fill!=value)
			{
				_fill = value;
				updateLayout();
			}
		}		
		
		final public function get shrinkOnly():Boolean
		{
			return _shrinkOnly;
		}
		
		public function set shrinkOnly(value:Boolean):void
		{
			if(_shrinkOnly!=value)
			{
				_shrinkOnly = value;
				updateLayout();
			}
		}
		
		final public function get autoSize():Boolean
		{
			return _autoSize;
		}
		
		public function set autoSize(value:Boolean):void
		{
			if(_autoSize!=value)
			{
				_autoSize = value;
				updateLayout();
			}
		}

		final public function get playing():Boolean
		{
			return _playing;
		}
		
		public function set playing(value:Boolean):void
		{
			if(_playing!=value)
			{
				_playing = value;
				if(_content is fairygui.display.MovieClip)
					fairygui.display.MovieClip(_content).playing = value;
				else if(_content is flash.display.MovieClip)
					flash.display.MovieClip(_content).stop();
				updateGear(5);
			}
		}
		
		final public function get frame():int
		{
			return _frame;
		}
		
		public function set frame(value:int):void
		{
			if(_frame!=value)
			{
				_frame = value;
				if(_content is fairygui.display.MovieClip)
					fairygui.display.MovieClip(_content).frame= value;
				else if(_content is flash.display.MovieClip)
				{
					if(_playing)
						flash.display.MovieClip(_content).gotoAndPlay(_frame+1);
					else
						flash.display.MovieClip(_content).gotoAndStop(_frame+1);
				}
				updateGear(5);
			}
		}
		
		final public function get color():uint
		{
			return _color;
		}
		
		public function set color(value:uint):void 
		{
			if(_color != value)
			{
				_color = value;
				updateGear(4);
				applyColor();
			}
		}
		
		private function applyColor():void
		{
			var ct:ColorTransform = _container.transform.colorTransform;
			ct.redMultiplier = ((_color>>16)&0xFF)/255;
			ct.greenMultiplier =  ((_color>>8)&0xFF)/255;
			ct.blueMultiplier = (_color&0xFF)/255;
			_container.transform.colorTransform = ct;
		}

		final public function get showErrorSign():Boolean
		{
			return _showErrorSign;
		}
		
		public function set showErrorSign(value:Boolean):void
		{
			_showErrorSign = value;
		}
		
		public function get texture():BitmapData
		{
			if(_content is Bitmap)
				return Bitmap(_content).bitmapData;
			else
				return null;
		}
		
		public function set texture(value:BitmapData):void
		{
			this.url = null;
			
			if(!(_content is Bitmap))
			{
				_content = new Bitmap();
				_container.addChild(_content);
			}
			else
				_container.addChild(_content);
			Bitmap(_content).bitmapData = value;
			_contentSourceWidth = value.width;
			_contentSourceHeight = value.height;
			updateLayout();
		}
		
		public function get component():GComponent
		{
			return _content2;
		}
		
		protected function loadContent():void
		{
			clearContent();
			
			if(!_url)
				return;

			if(ToolSet.startsWith(_url, "ui://"))
				loadFromPackage(_url);
			else
				loadExternal();
		}
		
		protected function loadFromPackage(itemURL:String):void
		{
			_contentItem = UIPackage.getItemByURL(itemURL);
			if(_contentItem!=null)
			{
				_contentItem = _contentItem.getBranch();
				_contentSourceWidth = _contentItem.width;
				_contentSourceHeight = _contentItem.height;

				if(_autoSize)
					this.setSize(_contentSourceWidth, _contentSourceHeight);

				_contentItem = _contentItem.getHighResolution();
				
				if(_contentItem.type==PackageItemType.Image)
				{
					if(_contentItem.loaded)
						__imageLoaded(_contentItem);
					else
					{
						_loading = 1;
						_contentItem.owner.addItemCallback(_contentItem, __imageLoaded);
					}
				}
				else if(_contentItem.type==PackageItemType.MovieClip)
				{
					if(_contentItem.loaded)
						__movieClipLoaded(_contentItem);
					else
					{
						_loading = 2;
						_contentItem.owner.addItemCallback(_contentItem, __movieClipLoaded);
					}
				}
				else if(_contentItem.type==PackageItemType.Swf)
				{
					_loading = 2;
					_contentItem.owner.addItemCallback(_contentItem, __swfLoaded);
				}
				else if(_contentItem.type==PackageItemType.Component)
				{
					var obj:GObject = UIPackage.createObjectFromURL(itemURL);
					if(!obj)
						setErrorState();
					else if(!(obj is GComponent))
					{
						obj.dispose();
						setErrorState();
					}
					else
					{
						_content2 = obj.asCom;
						_container.addChild(_content2.displayObject);
						updateLayout();
					}
				}
				else
					setErrorState();
			}
			else
				setErrorState();
		}
		
		private function __imageLoaded(pi:PackageItem):void
		{
			_loading = 0;

			if(pi.image==null)
			{
				setErrorState();
			}
			else
			{
				if(!(_content is Bitmap))
				{
					_content = new Bitmap();
					_container.addChild(_content);
				}
				else
					_container.addChild(_content);
				Bitmap(_content).bitmapData = pi.image;
				Bitmap(_content).smoothing = pi.smoothing;
				updateLayout();
			}
		}
		
		private function __movieClipLoaded(pi:PackageItem):void
		{
			_loading = 0;
			if(!(_content is fairygui.display.MovieClip))
			{
				_content = new fairygui.display.MovieClip();
				_container.addChild(_content);
			}
			else
				_container.addChild(_content);
			
			fairygui.display.MovieClip(_content).interval = pi.interval;
			fairygui.display.MovieClip(_content).frames = pi.frames;
			fairygui.display.MovieClip(_content).repeatDelay = pi.repeatDelay;
			fairygui.display.MovieClip(_content).swing = pi.swing;
			fairygui.display.MovieClip(_content).boundsRect = new Rectangle(0,0,pi.width,pi.height);

			updateLayout();
		}
		
		private function __swfLoaded(content:DisplayObject):void
		{
			_loading = 0;
			if(_content)
				_container.removeChild(_content);
			_content = DisplayObject(content);
			if(_content)
			{
				try
				{
					_container.addChild(_content);
				}
				catch(e:Error)
				{
					trace("__swfLoaded:"+e);
					_content = null;
				}
			}
			
			if(_content && (_content is flash.display.MovieClip))
			{
				if(_playing)
					flash.display.MovieClip(_content).gotoAndPlay(_frame+1);
				else
					flash.display.MovieClip(_content).gotoAndStop(_frame+1);
			}

			updateLayout();
		}
		
		protected function loadExternal():void
		{
			if(!_externalLoader)
			{
				_externalLoader = new Loader();
				_externalLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, __externalLoadCompleted);
				_externalLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, __externalLoadFailed);
			}
			_initExternalURLBeforeLoadSuccess = _url;
			_externalLoader.load(new URLRequest(url));
		}
		
		protected function freeExternal(content:DisplayObject):void
		{
			
		}
		
		final protected function onExternalLoadSuccess(content:DisplayObject):void
		{
			_content = content;
			_container.addChild(_content);
			if(content.loaderInfo && content.loaderInfo!=displayObject.loaderInfo)
			{
				_contentSourceWidth = content.loaderInfo.width;
				_contentSourceHeight =  content.loaderInfo.height;
			}
			else
			{
				_contentSourceWidth = content.width;
				_contentSourceHeight =  content.height;
			}
			updateLayout();
		}
		
		final protected function onExternalLoadFailed():void
		{
			setErrorState();
		}
		
		private function __externalLoadCompleted(evt:Event):void
		{
			if (_initExternalURLBeforeLoadSuccess == _url)
			{
				onExternalLoadSuccess(_externalLoader.content);
			}
			_initExternalURLBeforeLoadSuccess = null;
		}
		
		private function __externalLoadFailed(evt:Event):void
		{
			onExternalLoadFailed();
		}

		private function setErrorState():void
		{
			if (!_showErrorSign)
				return;
			
			if (_errorSign == null)
			{
				if (UIConfig.loaderErrorSign != null)
				{
					_errorSign = _errorSignPool.getObject(UIConfig.loaderErrorSign);
				}
			}
			
			if (_errorSign != null)
			{
				_errorSign.setSize(this.width, this.height);
				_container.addChild(_errorSign.displayObject);
			}
		}
		
		private function clearErrorState():void
		{
			if (_errorSign != null)
			{
				_container.removeChild(_errorSign.displayObject);
				_errorSignPool.returnObject(_errorSign);
				_errorSign = null;
			}
		}
		
		private function updateLayout():void
		{
			if(_content2==null && _content==null)
			{
				if(_autoSize)
				{
					_updatingLayout = true;
					this.setSize(50, 30);
					_updatingLayout = false;
				}
				return;
			}
			
			_contentWidth = _contentSourceWidth;
			_contentHeight = _contentSourceHeight;
			var sx:Number = 1, sy:Number = 1;

			if(_autoSize)
			{
				_updatingLayout = true;
				if(_contentWidth==0)
					_contentWidth = 50;
				if(_contentHeight==0)
					_contentHeight = 30;
				this.setSize(_contentWidth, _contentHeight);
				_updatingLayout = false;
				
				if(_width==_contentWidth && _height==_contentHeight) //可能由于大小限制
				{
					if(_content2!=null)
					{
						_content2.setXY(0, 0);
						_content2.setScale(sx, sy);
					}
					else
					{
						_content.x = 0;
						_content.y = 0;
						if(_content is Bitmap)
						{
							sx = _contentSourceWidth / _content.width;
							sy = _contentSourceHeight / _content.height;
						}
						_content.scaleX = sx;
						_content.scaleY = sy;
					}
					return;
				}
			}

			if(_fill!=LoaderFillType.None)
			{
				sx = _width/_contentSourceWidth;
				sy = _height/_contentSourceHeight;
				
				if(sx!=1 || sy!=1)
				{
					if (_fill == LoaderFillType.ScaleMatchHeight)
						sx = sy;
					else if (_fill == LoaderFillType.ScaleMatchWidth)
						sy = sx;
					else if (_fill == LoaderFillType.Scale)
					{
						if (sx > sy)
							sx = sy;
						else
							sy = sx;
					}
					else if (_fill == LoaderFillType.ScaleNoBorder)
					{
						if (sx > sy)
							sy = sx;
						else
							sx = sy;
					}
					
					if(_shrinkOnly)
					{
						if(sx>1)
							sx = 1;
						if(sy>1)
							sy = 1;
					}
					
					_contentWidth = _contentSourceWidth * sx;
					_contentHeight = _contentSourceHeight * sy;
				}
			}	
			
			if(_content2!=null)
			{
				_content2.setScale(sx, sy);
			}
			else if(_contentItem && _contentItem.type==PackageItemType.Image)
			{
				resizeImage();
			}
			else
			{
				_content.scaleX = sx;
				_content.scaleY = sy;
			}
			
			var nx:Number, ny:Number;
			if(_align==AlignType.Center)
				nx = int((this.width-_contentWidth)/2);
			else if(_align==AlignType.Right)
				nx = this.width-_contentWidth;
			else
				nx = 0;
			if(_verticalAlign==VertAlignType.Middle)
				ny = int((this.height-_contentHeight)/2);
			else if(_verticalAlign==VertAlignType.Bottom)
				ny = this.height-_contentHeight;
			else
				ny = 0;
			if(_content2!=null)
				_content2.setXY(nx, ny);
			else
			{
				_content.x = nx;
				_content.y = ny;
			}
		}
		
		private function clearContent():void 
		{
			clearErrorState();
			
			if(_content!=null && _content.parent!=null) 
				_container.removeChild(_content);
			
			if(_content2!=null)
			{
				_container.removeChild(_content2.displayObject);
				_content2.dispose();
				_content2 = null;
			}
			
			if(_contentItem!=null)
			{
				if(_loading==1)
					_contentItem.owner.removeItemCallback(_contentItem, __imageLoaded);
				else if(_loading==2)
					_contentItem.owner.removeItemCallback(_contentItem, __movieClipLoaded);
			}
			else
			{
				if(_content!=null)
					freeExternal(_content);
			}
			
			_contentItem = null;
			_loading = 0;
		}
		
		override protected function handleSizeChanged():void
		{
			if(!_updatingLayout)
				updateLayout();
		}
		
		private function resizeImage():void
		{
			var source:BitmapData = _contentItem.image;
			if(source==null)
				return;
			
			if(_contentItem.scale9Grid!=null || _contentItem.scaleByTile)
			{
				_content.scaleX = 1;
				_content.scaleY = 1;
				var sx:Number = _contentItem.width/_contentSourceWidth;
				var sy:Number = _contentItem.height/_contentSourceHeight;
				var w:int = _contentWidth * sx;
				var h:int = _contentHeight * sy;
				
				var oldBmd:BitmapData = Bitmap(_content).bitmapData;
				var newBmd:BitmapData;
				
				if(source.width==w && source.height==h)
					newBmd = source;
				else if(w==0 || h==0)
					newBmd = null;
				else if(_contentItem.scale9Grid!=null)
				{
					newBmd = ToolSet.scaleBitmapWith9Grid(source, 
						_contentItem.scale9Grid, w, h, _contentItem.smoothing, _contentItem.tileGridIndice);
				}
				else
					newBmd = ToolSet.tileBitmap(source, source.rect, w, h);
				
				if(oldBmd!=newBmd)
				{
					if(oldBmd && oldBmd!=source)
						oldBmd.dispose();
					Bitmap(_content).bitmapData = newBmd;
				}

				Bitmap(_content).width = _contentWidth;
				Bitmap(_content).height = _contentHeight;
			}
			else
			{
				_content.scaleX = _contentWidth/source.width;
				_content.scaleY = _contentHeight/source.height;
			}
		}
		
		override public function getProp(index:int):*
		{
			switch(index)
			{
				case ObjectPropID.Color:
					return this.color;
				case ObjectPropID.Playing:
					return this.playing;
				case ObjectPropID.Frame:
					return this.frame;
				case ObjectPropID.TimeScale:
					if(_content is fairygui.display.MovieClip)
						return fairygui.display.MovieClip(_content).timeScale;
					else
						return 1;
				default:
					return super.getProp(index);
			}
		}

		override public function setProp(index:int, value:*):void
		{
			switch(index)
			{
				case ObjectPropID.Color:
					this.color = value;
					break;
				case ObjectPropID.Playing:
					this.playing = value;
					break;
				case ObjectPropID.Frame:
					this.frame = value;
					break;
				case ObjectPropID.TimeScale:
					if(_content is fairygui.display.MovieClip)
						fairygui.display.MovieClip(_content).timeScale = value;
					break;
				case ObjectPropID.DeltaTime:
					if(_content is fairygui.display.MovieClip)
						fairygui.display.MovieClip(_content).advance(value);
					break;
				default:
					super.setProp(index, value);
					break;
			}
		}

		override public function setup_beforeAdd(xml:XML):void
		{
			super.setup_beforeAdd(xml);
			
			var str:String;
			str = xml.@url;
			if(str)
				_url = str;
			
			str = xml.@align;
			if(str)
				_align = AlignType.parse(str);
			
			str = xml.@vAlign;
			if(str)
				_verticalAlign = VertAlignType.parse(str);
			
			str = xml.@fill;
			if(str)
				_fill = LoaderFillType.parse(str);
			
			_shrinkOnly = xml.@shrinkOnly=="true";
			
			_autoSize = xml.@autoSize=="true";
			
			str = xml.@errorSign;
			if(str)
				_showErrorSign = str=="true";
			
			_playing = xml.@playing != "false";
			
			str = xml.@color;
			if(str)
				this.color = ToolSet.convertFromHtmlColor(str);
			
			if(_url)
				loadContent();
		}
	}
}
