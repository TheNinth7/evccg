import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;

// Base class for all drawing elements that consists of other drawing elements
class EvccContainerBlock extends EvccBlock {
    protected var _elements as Array<EvccBlock> = new Array<EvccBlock>[0];

    function initialize( options as DbOptions ) {
        EvccBlock.initialize( options );
    }

    function getElementCount() as Number {
        return _elements.size();
    }

    (:exclForGlanceTiny :exclForGlanceNone) 
    function getElements() as Array<EvccBlock> {
        return _elements;
    }

    // Add text is implemented differently for vertical and horizontal containers
    function addTextWithOptions( text as String, options as DbOptions ) as Void {}
    function addText( text as String ) as Void {
        addTextWithOptions( text, {} as DbOptions );
    }

    // Functions to add elements
    function addError( text as String, options as DbOptions ) as Void {
        options[:color] = EvccColors.ERROR;
        options[:parent] = self;
        _elements.add( new EvccTextBlock( text, options ) );
    }
    function addBitmap( reference as ResourceId, options as DbOptions ) as Void {
        options[:parent] = self;
        _elements.add( new EvccBitmapBlock( reference, options ) );
    }
    
    function addIcon( icon as EvccIconBlock.Icon, options as DbOptions ) as Void {
        options[:parent] = self;
        
        // Special handling for the power flow and active phases icons
        // power flow is only shown if power is not equal 0, and
        // active phases is only shown if the loadpoint is charging
        if( ( icon != EvccIconBlock.ICON_POWER_FLOW || options[:power] != 0 ) &&
            ( icon != EvccIconBlock.ICON_ACTIVE_PHASES || options[:charging] == true ) )  
        {
            _elements.add( new EvccIconBlock( icon, options ) );
        }
    }

    function addBlock( block as EvccBlock ) as Void {
        block.setParent( self );
        _elements.add( block );
    }

    // For containers, the resetCache function additionally resets all elements
    public function resetCache( resetType as Symbol, direction as Symbol ) as Void {
        EvccBlock.resetCache( resetType, direction );
        if( direction == :resetDirectionDown || direction == :resetDirectionBoth ) {
            for( var i = 0; i < _elements.size(); i++ ) {
                _elements[i].resetCache( resetType, :resetDirectionDown );
            }
        }
    }

    // The preparedDraw is different for horizontal and vertical block, but then
    // drawing the elements is the same for both and thus done here, in the general
    // container class
    function drawPrepared( dc as Dc ) as Void
    {
        for( var i = 0; i < _elements.size(); i++ ) {
            _elements[i].drawPrepared( dc );
        }
    }
}
