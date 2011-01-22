//--------------------------------------------------------------------------
// Authors:	(C)2003 André D. / Uli H.
//--------------------------------------------------------------------------
/* This is the original header from TD SVN, patched to be usable with
   newer compilers. Only the typedefs of OutDevice and PesType have been
   shifted to the correct place */

#ifndef TS_H
#define TS_H

#pragma pack(1)

#define SIZEOF_PMT_MAP_TYPE	5
#define LENGTH_TABLE_HEADER	3
#define LENGTH_TABLE_CRC	4
#define FILTER_LENGTH		16

typedef struct demux_filter_para filter_para;
typedef struct demux_pes_para Pes_para;
typedef struct UnloaderConfig_t UnloaderConfig;
typedef struct demux_bucket_para bucket_para;

typedef enum unloader_type_t {
	UNLOADER_TYPE_TRANSPORT = 0x0,				// all 188 bytes of the transport packet.
	UNLOADER_TYPE_ADAPTATION = 0x1,				// the 4-byte transport header and the adaptation field.
	UNLOADER_TYPE_ADAPTATION_PRIVATE = 0x2,		// the private data field within the adaptation field.
	UNLOADER_TYPE_PAYLOAD = 0x3,				// the transport packet payload.
	UNLOADER_TYPE_PAYLOAD_AND_BUCKET = 0x4,		// same as Payload, and with the transport header and the adaptation header delivered to the bucket queue.
	UNLOADER_TYPE_BUCKET = 0x5,					// Transport header and adaptation header delivered to the bucket queue.
	UNLOADER_TYPE_PSI = 0x8,					// deliver table sections.
	UNLOADER_TYPE_FILTER_PSI = 0x9,				// deliver table sections that match at least one of the table section filters defined for the queue.
	UNLOADER_TYPE_PSI_CRC = 0xa,				// deliver table sections and check them for CRC32 errors.
	UNLOADER_TYPE_FILTER_PSI_CRC = 0xb,			// the combination of the two previous types.
	UNLOADER_TYPE_PSI_BUCKET = 0xc,				// the same as Table Section, with the transport header and adaptation field delivered to the bucket queue.
	UNLOADER_TYPE_FILTER_PSI_BUCKET = 0xd,		// the same as Table Section with Filtering, with the addition of delivering the transport header and adaptation field to the bucket queue.
	UNLOADER_TYPE_PSI_CRC_BUCKET = 0xe,			// same as Table Section with CRC32 Checking, with the addition of delivering the transport header and the adaptation field to the bucket queue.
	UNLOADER_TYPE_FILTER_PSI_CRC_BUCKET = 0xf,	// same as Table Section with Filter and CRC32 Checking, with the addition of delivering the transport header and adaptation field to the bucket queue.
	UNLOADER_TYPE_UNDEFINED = 0x10,
	UNLOADER_TYPE_MEASURE_DUMMY = 0x83
} UNLOADER_TYPE;


struct  UnloaderConfig_t {
	UNLOADER_TYPE   unloader_type;			// specifies which data from the packet is to be delivered to the queue.
	unsigned long   threshold;				// This value indicates the number of 256 byte boundaries before generating an interrupt for this queue.
};


struct demux_bucket_para {
	struct UnloaderConfig_t unloader;
};


typedef enum stream_source_t {
	INPUT_FROM_CHANNEL0,
	INPUT_FROM_CHANNEL1,
	INPUT_FROM_1394,
	INPUT_FROM_PVR
} STREAM_SOURCE;


enum _OutDevice {
	OUT_DECODER,			// 0 = output to A/V decoder directly
	OUT_MEMORY,				// 1 = output to memory
	OUT_NOTHING				// 2 = no output
};
typedef enum _OutDevice OutDevice;



//--------------------------------------------------------------------------
enum P_Type {
	DMX_PES_AUDIO,			// 0 = Audio PES
	DMX_PES_VIDEO,			// 1 = Video
	DMX_PES_TELETEXT,		// 2 = Teletext
	DMX_PES_SUBTITLE,		// 3 = subtitle
	DMX_PES_PCR,			// 4 = PCR
	DMX_PES_OTHER			// 5 = other
};
typedef enum P_Type PesType;



typedef enum _XPDemuxFlags {
	XPDF_IMMEDIATE_START  = (1 << 0), // immediately start filter
	XPDF_IGNORE_CC        = (1 << 1), // ignore packet's continuity counter
	XPDF_NO_CRC           = (1 << 2), // no crc32 checking on sectionfilters
	XPDF_ONESHOT          = (1 << 3), // STOP filter when section received
} XPDemuxFlags;









//--------------------------------------------------------------------------
struct demux_filter_para {
	unsigned char  filter[FILTER_LENGTH];	// table section filter
	unsigned char  mask[FILTER_LENGTH];		// table section filter mask
	unsigned char  positive[FILTER_LENGTH];	// positive filterring enabler
	signed int     filter_length;			// number of bytes of the filter
	unsigned short pid;						// table section program PID
	unsigned int   timeout;
	unsigned short   flags;
};


struct demux_pes_para {
	unsigned short pid;						// PES data program PID
	OutDevice output;						// Output device after recieving the PES
	PesType pesType;						// PES data type
	UnloaderConfig unloader;				// PES unloader configuration (only available for OUT_MEMORY)
	unsigned short flags;
};




//--------------------------------------------------------------------------
typedef struct pat_map_type {
	unsigned programNumber_hi:8;			// program id for the map pid
	unsigned programNumber_lo:8;			// program id for the map pid
	unsigned reserved:3;
	unsigned pid:13;						// network or program Pid number
}PAT_MAP_TYPE, *PAT_MAP_PTR;


//--------------------------------------------------------------------------
typedef struct pat_type {
	unsigned table_id:8;					// table type
	unsigned syntax_ind:1;					// section syntax indicator
	unsigned reserved_1:3;					//
	unsigned sectionLength:12;				// length of the remaining data
	unsigned streamId_hi:8;					// transport stream id
	unsigned streamId_lo:8;					// transport stream id
	unsigned reserved_2:2;
	unsigned version:5;						// version of the PAT
	unsigned current_next:1;				// 1=use current, 0=use next
	unsigned sectionNumber:8;				// current section number
	unsigned lastSectionNumber:8;			// last section number for the PAT
	PAT_MAP_TYPE map[1];					// 1 or more program/pid mapping
}PAT_TYPE, *PAT_PTR;




//--------------------------------------------------------------------------
typedef struct pmt_map_type {
	unsigned streamType:8;					// type of elementary stream
	unsigned reserved_1:3;
	unsigned pid:13;						// elementary stream pid number
	unsigned reserved_2:4;
	unsigned info_len1:4;					// length of descriptor
	unsigned info_len2:8;					// length of descriptor
}PMT_MAP_TYPE, *PMT_MAP_PTR;


typedef struct pmtmap_type {				// flow's version
	unsigned streamType:8;					// type of elementary stream
	unsigned reserved_1:3;
	unsigned pid:13;						// elementary stream pid number
	unsigned reserved_2:4;
	unsigned info_len:12;					// length of descriptor
}PMTMAP_TYPE, *PMTMAP_PTR;


typedef struct pmt_type {
	unsigned table_id:8;					// table type
	unsigned syntax_ind:1;					// section syntax indicator
	unsigned reserved_1:3;
	unsigned sectionLength:12;				// length of the remaining data
	unsigned programId_hi:8;				// program number
	unsigned programId_lo:8;				// program number
	unsigned reserved_2:2;
	unsigned version:5;						// version of the PAT
	unsigned current_next:1;				// 1=use current, 0=use next
	unsigned sectionNumber:8;				// current section number
	unsigned lastSectionNumber:8;			// last section number for the PAT
	unsigned reserved_3:3;
	unsigned pcr_pid:13;					// pid containing pcrs
	unsigned reserved_4:4;
	unsigned program_info_length:12;		// number of bytes in descriptors
}PMT_TYPE, *PMT_PTR;


//--------------------------------------------------------------------------
typedef struct sdt_type {
	unsigned table_id:8;
	unsigned section_syntax_indicator:1;
	unsigned reserved_1:1;
	unsigned reserved_2:2;
	unsigned section_length:12;
	unsigned transport_stream_id:16;
	unsigned reserved_3:2;
	unsigned version_number:5;
	unsigned current_next_indicator:1;
	unsigned section_number:8;
	unsigned last_section_number:8;
	unsigned original_network_id:16;
	unsigned reserved_4:8;
}SDT_TYPE, *SDT_PTR;


typedef struct sdt_map_type {
	unsigned service_id:16;
	unsigned reserved_1:6;
	unsigned EIT_schedule_flag:1;
	unsigned EIT_present_following_flag:1;
	unsigned running_status:3;
	unsigned free_CA_mode:1;
	unsigned descriptors_loop_length:12;
}SDT_MAP_TYPE, *SDT_MAP_PTR;


#pragma pack()


//--------------------------------------------------------------------------
typedef struct ca_descr {
        unsigned int index;
        unsigned int parity;			// 0 == even, 1 == odd
        unsigned char cw[8];
} ca_descr_t;


typedef struct ca_pid {
        unsigned int pid;
        signed int index;						// -1 == disable
} ca_pid_t;


//--------------------------------------------------------------------------
typedef struct STREAM_MEASURE {
	unsigned int rx_packets;
	unsigned int rx_bytes;
	unsigned int rx_time_us;
} S_STREAM_MEASURE;



//--------------------------------------------------------------------------
//Demux API ioctl command definition
#define DEMUX_START						_IO (0x78,  1)
#define DEMUX_STOP						_IO (0x78,  2)
#define DEMUX_FILTER_SET				_IOW(0x78,  3, struct demux_filter_para)
#define DEMUX_FILTER_PES_SET			_IOW(0x78,  4, struct demux_pes_para)
#define DEMUX_SET_BUFFER_SIZE			_IOW(0x78,  5, unsigned long)
#define DEMUX_FILTER_TS_SET				_IO (0x78,  6)
#define DEMUX_SELECT_SOURCE				_IOW(0x78,  7, STREAM_SOURCE)
#define DEMUX_GET_FILTER_NUM			_IOR(0x78,  8, unsigned int)
#define DEMUX_SET_DEFAULT_FILTER_LENGTH	_IOW(0x78,  9, unsigned int)
#define DEMUX_FILTER_BUCKET_SET			_IOW(0x78, 10, struct demux_bucket_para)
#define DEMUX_GET_CURRENT_STC			_IOR(0x78, 14, STC_TYPE)
#define DEMUX_PRINTK					_IO (0x78, 20)

#define CA_INTERN_ENABLE				_IO (0x78, 50)
#define CA_INTERN_DISABLE				_IO (0x78, 51)
#define CA_CWCOUNT_READ					_IOR(0x78, 62, unsigned int)
#define CA_SET_DESCR					_IOW(0x78, 134, ca_descr_t)
#define CA_SET_PID						_IOW(0x78, 135, ca_pid_t)
#define CA_GET_SCRAMBLING_STATUS		_IO (0x78, 136)

#define DEMUX_DEBUG						_IO (0x78, 150)
#define DEMUX_DEBUG1					_IO (0x78, 151)
#define DEMUX_DEBUG2					_IO (0x78, 152)
#define DEMUX_DEBUG3					_IO (0x78, 153)
#define DEMUX_DEBUG4					_IO (0x78, 154)
#define DEMUX_DEBUG5					_IO (0x78, 155)

#define DEMUX_GET_MEASURE_TIMING		_IOR(0x78, 160, S_STREAM_MEASURE)
#define DEMUX_SET_MEASURE_BYTES			_IOW(0x78, 161, unsigned int)
#define DEMUX_SET_MEASURE_TIME			_IOW(0x78, 162, unsigned int)

#define DEMUX_SET_API_VERSION			_IOW(0x78, 254, unsigned int)
#define DEMUX_GET_API_VERSION			_IOR(0x78, 255, unsigned int *)

#endif

