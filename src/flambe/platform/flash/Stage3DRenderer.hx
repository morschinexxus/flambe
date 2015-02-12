//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.flash;

import flash.display3D.Context3D;
import flash.display.BitmapData;
import flash.display.Stage3D;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.Lib;
import flash.geom.Rectangle;
import haxe.io.Bytes;

import flambe.asset.AssetEntry;
import flambe.display.Graphics;
import flambe.display.Texture;
import flambe.display.Sprite;
import flambe.subsystem.RendererSystem;
import flambe.util.Assert;
import flambe.util.Value;

class Stage3DRenderer
    implements InternalRenderer<BitmapData>
{
    public var type (get, null) :RendererType;
    public var maxTextureSize (get, null) :Int;
    public var hasGPU (get, null) :Value<Bool>;

    public var graphics :InternalGraphics = null;

    public var batcher (default, null) :Stage3DBatcher;

    public function new (?context:Stage3DContext)
    {
        _hasGPU = new Value<Bool>(false);
        
        if(context == null) {
            // Use the first available Stage3D
            var stage = Lib.current.stage;
            for (stage3D in stage.stage3Ds) {
                if (stage3D.context3D == null) {
                    stage.addEventListener(Event.RESIZE, onResize);

                    stage3D.addEventListener(Event.CONTEXT3D_CREATE, onContext3DCreate);
                    stage3D.addEventListener(ErrorEvent.ERROR, onError);

                    // The constrained profile is only available in 11.4
                    if ((untyped stage3D).requestContext3D.length >= 2) {
                        (untyped stage3D).requestContext3D("auto", "baselineConstrained");
                    } else {
                        stage3D.requestContext3D();
                    }
                    return;
                }
            }
            Log.error("No free Stage3Ds available!");
        } else {
            useContext(context);
        }
    }

    inline private function get_type () :RendererType
    {
        return Stage3D;
    }

    inline private function get_maxTextureSize () :Int
    {
        return 2048; // The max supported by BASELINE_CONSTRAINED
    }

    inline private function get_hasGPU () :Value<Bool>
    {
        return _hasGPU;
    }

    public function createTextureFromImage (bitmapData :BitmapData) :Stage3DTexture
    {
        if (_context == null) {
            return null; // No Stage3D context yet
        }

        var bitmapData :BitmapData = cast bitmapData;
        var root = new Stage3DTextureRoot(this, bitmapData.width, bitmapData.height);
        root.init(_context.context3D, false);
        root.uploadBitmapData(bitmapData);
        return root.createTexture(bitmapData.width, bitmapData.height);
    }

    public function createTexture (width :Int, height :Int) :Stage3DTexture
    {
        if (_context == null) {
            return null; // No Stage3D context yet
        }

        var root = new Stage3DTextureRoot(this, width, height);
        root.init(_context.context3D, true);
        return root.createTexture(width, height);
    }

    public function getCompressedTextureFormats () :Array<AssetFormat>
    {
        return [];
    }

    public function createCompressedTexture (format :AssetFormat, data :Bytes) :Stage3DTexture
    {
        Assert.fail(); // Unsupported
        return null;
    }

    public function createGraphics (renderTarget :Stage3DTextureRoot) :Stage3DGraphics
    {
        return new Stage3DGraphics(batcher, renderTarget);
    }
    public function render ()
    { 

        if (graphics != null) {
            willRender();
            Sprite.render(System.root, graphics);
            didRender();
        }

    }
    public function willRender ()
    {
#if flambe_debug_renderer
        trace(">>> begin");
#end
        graphics.willRender();
    }

    public function didRender ()
    {
        graphics.didRender();
#if flambe_debug_renderer
     
#end
    }

    private function onContext3DCreate (event :Event)
    {
        var stage3D :Stage3D = event.target;
        useContext(new Stage3DContext(stage3D.context3D, false));
    }

    private function useContext (context:Stage3DContext)
    {
      _context = context;

      if(_context.shared) {
        Log.info("Using shared context", ["driver", _context.context3D.driverInfo]);
#if flambe_debug_renderer
       _context.context3D.enableErrorChecking = true;
#end
       
      } else {
        Log.info("Using exclusive context", ["driver", _context.context3D.driverInfo]);
      }

        batcher = new Stage3DBatcher(_context);
        graphics = createGraphics(null);
        onResize(null);
      
        // Signal that the GPU context was (re)created
        hasGPU._ = false;
        hasGPU._ = true;
    }

    private function onError (event :ErrorEvent)
    {
        Log.error("Unexpected Stage3D failure!", ["error", event.text]);
    }

    private function onResize (_)
    {
       //if (!_context.shared) {
           var stage = Lib.current.stage;
           trace("onResize",stage.stageWidth, stage.stageHeight);
           batcher.resizeBackbuffer(stage.stageWidth, stage.stageHeight);
           graphics.onResize(stage.stageWidth, stage.stageHeight);
       // }
    }

  /*  private var _context3D :Context3D;

        if (_context != null) {
            var stage = Lib.current.stage;
            _context.context3D.configureBackBuffer(stage.stageWidth, stage.stageHeight, 2, false);
            _graphics.onResize(stage.stageWidth, stage.stageHeight);
        }*/
//    }

    private var _hasGPU :Value<Bool>;
    private var _context :Context;
    private var _graphics :Stage3DGraphics;
}
