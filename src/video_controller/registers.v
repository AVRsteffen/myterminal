localparam
    VIDEO_NOP              = 'd0,
    VIDEO_SET_BASE_ADDRESS = 'd1,
    VIDEO_SET_FIRST_ROW    = 'd2,			// 'd2

    COLUMNS                = 'd40,			// 'd80
    COLUMNS_REAL           = 'd128,			// 'd128
    ROWS                   = 'd24,			// 'd51
    CHARATTR_SIZE          = 'd4,
    ROW_SIZE               = COLUMNS_REAL * CHARATTR_SIZE,	// 128*4 = 512
    PAGE_SIZE              = ROW_SIZE * ROWS   				// 512*24 = 12288 
	;
