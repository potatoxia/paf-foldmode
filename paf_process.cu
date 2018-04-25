#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#endif

#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <inttypes.h>

#include "paf_process.cuh"
#include "process.cuh"
#include "cudautil.cuh"

int main(int argc, char *argv[])
{
  int arg;
  conf_t conf;

  /* Setup log interface */
  conf.log = multilog_open("paf_process", 0);
  conf.fp_log = fopen("paf_process.log", "ab+");
  multilog_add(conf.log, conf.fp_log);
  multilog(conf.log, LOG_INFO, "START PAF_PROCESS\n");
  
  /* Initial part */  
  while((arg=getopt(argc,argv,"c:o:i:d:s:h:n:p:r:g:f:b:")) != -1)
    {
      switch(arg)
	{	  
	case 'h':	  	  
	  sscanf(optarg, "%s", conf.hfname);
	  break;

	case 'c':
	  sscanf(optarg, "%lf", &conf.rbufin_ndfstp);
	  break;
	  
	case 's':
	  sscanf(optarg, "%d", &conf.sod);
	  break;
	  
	case 'o':	  
	  if (sscanf (optarg, "%x", &conf.key_out) != 1)
	    {
	      multilog (conf.log, LOG_ERR, "Could not parse key from %s, which happens at \"%s\", line [%d].\n", optarg, __FILE__, __LINE__);
	      fprintf (stderr, "Could not parse key from %s, which happens at \"%s\", line [%d].\n", optarg, __FILE__, __LINE__);
	      return EXIT_FAILURE;
	    }
	  break;
	  
	case 'i':	  
	  if (sscanf (optarg, "%x", &conf.key_in) != 1)
	    {
	      multilog (conf.log, LOG_ERR, "Could not parse key from %s, which happens at \"%s\", line [%d].\n", optarg, __FILE__, __LINE__);
	      fprintf (stderr, "Could not parse key from %s, which happens at \"%s\", line [%d].\n", optarg, __FILE__, __LINE__);
	      return EXIT_FAILURE;
	    }
	  break;
	  
	case 'd':
	  sscanf(optarg, "%d", &conf.device_id);
	  break;

	case 'n':
	  sscanf(optarg, "%d", &conf.nstream);
	  break;
	  
	case 'p':
	  sscanf(optarg, "%d", &conf.stream_ndfstp);
	  break;
	  
	case 'g':
	  sscanf(optarg, "%d", &conf.debug);
	  break;
	  
	case 'f':
	  sscanf(optarg, "%s", conf.dir);
	  break;
	  
	case 'b':
	  sscanf(optarg, "%d", &conf.nrun_blk);
	  break;	  
	}
    }
  
#ifdef DEBUG
  struct timespec start, stop;
  double elapsed_time;
  clock_gettime(CLOCK_REALTIME, &start);
#endif
  init_process(&conf);
#ifdef DEBUG
      clock_gettime(CLOCK_REALTIME, &stop);
      elapsed_time = (stop.tv_sec - start.tv_sec) + (stop.tv_nsec - start.tv_nsec)/1000000000.0L;
      fprintf(stdout, "elapsed time for processing prepare is %f s\n\n\n\n\n", elapsed_time);
#endif
      
  /* Check on-board gpus */
//#ifdef DEBUG
//  int deviceCount, device;
//  struct cudaDeviceProp properties;
//  CudaSafeCall(cudaGetDeviceCount(&deviceCount));
//  fprintf(stdout, "Number of devices %d\n", deviceCount);
//  for(device = 0; device < deviceCount; ++device)
//    {
//      cudaGetDeviceProperties(&properties, device);
//      if (properties.major != 9999) /* 9999 means emulation only */
//  	{
//  	  printf("multiProcessorCount %d\n",properties.multiProcessorCount);
//  	  printf("maxThreadsPerMultiProcessor %d\n",properties.maxThreadsPerMultiProcessor);
//  	  printf("pciDeviceID %d\n",properties.pciDeviceID);
//  	  printf("pciBusID %d\n",properties.pciBusID);
//  	}
//    }
//#endif
  
  /* Play with data */
#ifdef DEBUG
  clock_gettime(CLOCK_REALTIME, &start);
#endif
  if(do_process(conf))
    {
      multilog (conf.log, LOG_ERR, "Can not finish the process, which happens at \"%s\", line [%d].\n", __FILE__, __LINE__);
      fprintf(stderr, "Can not finish the process, which happens at \"%s\", line [%d].\n", __FILE__, __LINE__);
      return EXIT_FAILURE;
    }
  #ifdef DEBUG
      clock_gettime(CLOCK_REALTIME, &stop);
      elapsed_time = (stop.tv_sec - start.tv_sec) + (stop.tv_nsec - start.tv_nsec)/1000000000.0L;
      fprintf(stdout, "elapsed time for data processing is %f s\n", elapsed_time);
#endif

  destroy_process(conf);

  /* Destory log interface */
  multilog(conf.log, LOG_INFO, "FINISH PAF_PROCESS\n\n");
  multilog_close(conf.log);
  fclose(conf.fp_log);
  
  return EXIT_SUCCESS;
}