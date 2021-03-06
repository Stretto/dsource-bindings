import freetype.ft;

import std.math;
import std.string;
import std.stdio;

const int WIDTH = 640;
const int HEIGHT = 480;


/* origin is the upper left corner */
ubyte[WIDTH][HEIGHT] image;


/* Replace this function with something useful. */

void drawBitmap( FT_Bitmap* bitmap, FT_Int x, FT_Int y )
{
	FT_Int i, j, p, q;
	FT_Int  x_max = x + bitmap.width;
	FT_Int  y_max = y + bitmap.rows;
	for ( i = x, p = 0; i < x_max; i++, p++ )
	{
		for ( j = y, q = 0; j < y_max; j++, q++ )
		{
			if ( i >= WIDTH || j >= HEIGHT )
				continue;
			image[j][i] |= bitmap.buffer[q * bitmap.width + p];
		}
	}
}

void showImage()
{
	int  i, j;

	for ( i = 0; i < HEIGHT; i++ )
	{
		for ( j = 0; j < WIDTH; j++ )
			putchar( image[i][j] == 0 ? ' ' : image[i][j] < 128 ? '+' : '*' );
		putchar( '\n' );
	}
}

int	main( char[][]  args )
{
	FT_Library    library;
	FT_Face       face;

	FT_GlyphSlot  slot;
	FT_Matrix     matrix;                 /* transformation matrix */
	FT_UInt       glyph_index;
	FT_Vector     pen;                    /* untransformed origin  */
	FT_Error      error;

	char[]        filename;
	char*         text;

	double        angle;
	int           target_height;
	int           n, num_chars;
		
	
	filename      = args[1].dup;                           /* first argument     */
	text          = toStringz(args[2].dup);                /* second argument    */
	num_chars     = strlen( text );
	angle         = ( 25.0 / 360 ) * 3.14159 * 2;      /* use 25 degrees     */
	target_height = HEIGHT;

	error = FT_Init_FreeType( &library );              /* initialize library */
	/* error handling omitted */
	
	error = FT_New_Face( library, toStringz(args[1]), 0, &face ); /* create face object */
	/* error handling omitted */
	
	/* use 50pt at 100dpi */
	error = FT_Set_Char_Size( face, 50 * 64, 0, 100, 0 );  /* set character size */
	/* error handling omitted */
	
	slot = face.glyph;
	
	/* set up matrix */
	matrix.xx = cast(FT_Fixed)( cos( angle ) * 0x10000L );
	matrix.xy = cast(FT_Fixed)(-sin( angle ) * 0x10000L );
	matrix.yx = cast(FT_Fixed)( sin( angle ) * 0x10000L );
	matrix.yy = cast(FT_Fixed)( cos( angle ) * 0x10000L );	

	/* the pen position in 26.6 cartesian space coordinates; */
	/* start at (300,200) relative to the upper left corner  */
	pen.x = 300 * 64;
	pen.y = ( target_height - 200 ) * 64;

	for ( n = 0; n < num_chars; n++ )
	{
		/* set transformation */
		FT_Set_Transform( face, &matrix, &pen );
	
		/* load glyph image into the slot (erase previous one) */
		error = FT_Load_Char( face, text[n], FT_LOAD_RENDER );
		if ( error )
			continue;                 /* ignore errors */

		/* now, draw to our target surface (convert position) */
		drawBitmap( &slot.bitmap, slot.bitmap_left, target_height - slot.bitmap_top );
	
		/* increment pen position */
		pen.x += slot.advance.x;
		pen.y += slot.advance.y;
	}

	showImage();
	
	FT_Done_Face    ( face );
	FT_Done_FreeType( library );
	
	return 0;
}

/* EOF */
