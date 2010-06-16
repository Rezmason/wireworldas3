/*
	Adobe Systems Incorporated(r) Source Code License Agreement
	Copyright(c) 2005 Adobe Systems Incorporated. All rights reserved.
	
	Please read this Source Code License Agreement carefully before using
	the source code.
	
	Adobe Systems Incorporated grants to you a perpetual, worldwide, non-exclusive, 
	no-charge, royalty-free, irrevocable copyright license, to reproduce,
	prepare derivative works of, publicly display, publicly perform, and
	distribute this source code and such derivative works in source or 
	object code form without any attribution requirements.  
	
	The name "Adobe Systems Incorporated" must not be used to endorse or promote products
	derived from the source code without prior written permission.
	
	You agree to indemnify, hold harmless and defend Adobe Systems Incorporated from and
	against any loss, damage, claims or lawsuits, including attorney's 
	fees that arise or result from your use or distribution of the source 
	code.
	
	THIS SOURCE CODE IS PROVIDED "AS IS" AND "WITH ALL FAULTS", WITHOUT 
	ANY TECHNICAL SUPPORT OR ANY EXPRESSED OR IMPLIED WARRANTIES, INCLUDING,
	BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
	FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  ALSO, THERE IS NO WARRANTY OF 
	NON-INFRINGEMENT, TITLE OR QUIET ENJOYMENT.  IN NO EVENT SHALL MACROMEDIA
	OR ITS SUPPLIERS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
	EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
	PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
	OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
	WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR 
	OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOURCE CODE, EVEN IF
	ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
package com.adobe.images
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.*;
	import flash.utils.ByteArray;

	/**
	 * Class that converts BitmapData into a valid PNG
	 */	
	public class PNGEncoder
	{
		
		// MODIFIED to support non-BitmapData type things.
		// It just needs a width, height and function specified.
		
		/**
		 * Created a PNG image from the specified BitmapData
		 *
		 * @param image The BitmapData that will be converted into the PNG format.
		 * @return a ByteArray representing the PNG encoded image data.
		 * @langversion ActionScript 3.0
		 * @playerversion Flash 9.0
		 * @tiptext
		 */			
	    public static function encode(img:BitmapData = null, w:int = 0, h:int = 0, transparent:Boolean = true, func:Function = null):ByteArray {
	    	
	    	if (img) {
	    		w ||= img.width;
	    		h ||= img.height;
	    		transparent &&= img.transparent;
	    		func ||= transparent ? img.getPixel32 : img.getPixel;
	    	}
	    	
	        // Create output byte array
	        var png:ByteArray = new ByteArray();
	        
	        if (!w || !h || func == null) return png;
	        
	        // Write PNG signature
	        png.writeUnsignedInt(0x89504e47);
	        png.writeUnsignedInt(0x0D0A1A0A);
	        // Build IHDR chunk
	        var IHDR:ByteArray = new ByteArray();
	        IHDR.writeInt(w);
	        IHDR.writeInt(h);
	        IHDR.writeUnsignedInt(0x08060000); // 32bit RGBA
	        IHDR.writeByte(0);
	        writeChunk(png,0x49484452,IHDR);
	        // Build IDAT chunk
	        var IDAT:ByteArray= new ByteArray();
	        for(var i:int=0;i < h;i++) {
	            // no filter
	            IDAT.writeByte(0);
	            var p:uint;
	            var j:int;
	            if ( !transparent ) {
	                for(j=0;j < w;j++) {
	                    p = func(j,i);
	                    IDAT.writeUnsignedInt(uint(((p&0xFFFFFF) << 8)|0xFF));
	                }
	            } else {
	                for(j=0;j < w;j++) {
	                    p = func(j,i);
	                    IDAT.writeUnsignedInt(uint(((p&0xFFFFFF) << 8)|(p>>>24)));
	                }
	            }
	        }
	        IDAT.compress();
	        writeChunk(png,0x49444154,IDAT);
	        // Build IEND chunk
	        writeChunk(png,0x49454E44,null);
	        // return PNG
	        return png;
	    }
	
	    private static var crcTable:Array;
	    private static var crcTableComputed:Boolean = false;
	
	    private static function writeChunk(png:ByteArray, 
	            type:uint, data:ByteArray):void {
	        if (!crcTableComputed) {
	            crcTableComputed = true;
	            crcTable = [];
	            var c:uint;
	            for (var n:uint = 0; n < 256; n++) {
	                c = n;
	                for (var k:uint = 0; k < 8; k++) {
	                    if (c & 1) {
	                        c = uint(uint(0xedb88320) ^ 
	                            uint(c >>> 1));
	                    } else {
	                        c = uint(c >>> 1);
	                    }
	                }
	                crcTable[n] = c;
	            }
	        }
	        var len:uint = 0;
	        if (data != null) {
	            len = data.length;
	        }
	        png.writeUnsignedInt(len);
	        var p:uint = png.position;
	        png.writeUnsignedInt(type);
	        if ( data != null ) {
	            png.writeBytes(data);
	        }
	        var e:uint = png.position;
	        png.position = p;
	        c = 0xffffffff;
	        for (var i:int = 0; i < (e-p); i++) {
	            c = uint(crcTable[
	                (c ^ png.readUnsignedByte()) & 
	                uint(0xff)] ^ uint(c >>> 8));
	        }
	        c = uint(c^uint(0xffffffff));
	        png.position = e;
	        png.writeUnsignedInt(c);
	    }
	}
}