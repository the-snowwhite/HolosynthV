/** @file simple_client.c
 *
 * @brief This simple client demonstrates the most basic features of JACK
 * as they would be used by many applications.
 */

#include <stdio.h>
#include <errno.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <stdint.h>
#include <fcntl.h>
#include <sys/mman.h>

#include <jack/jack.h>

jack_port_t *input_port_l;
jack_port_t *input_port_r;
jack_port_t *output_port_l;
jack_port_t *output_port_r;
jack_client_t *client;

#define HW_REGS_SPAN ( 4096 )
//#define FILE_DEV "/dev/uio0"
#define FILE_DEV "/dev/uio4"

bool m_bInitSuccess;
int fd;
void *virtual_base;
uint32_t *uio_mem_addr=NULL;

bool UioInit();
jack_default_audio_sample_t AudioRegGet(unsigned int regadr);

bool UioInit()
{
    bool bSuccess = true;
    // Open /dev/uiox
    if ( ( fd = open ( FILE_DEV, ( O_RDWR | O_SYNC ) ) ) == -1 ) {
        bSuccess = false;
        close ( fd );
    }

    virtual_base = mmap( NULL, HW_REGS_SPAN, ( PROT_READ | PROT_WRITE ), MAP_SHARED, fd, 0);

    if ( virtual_base == MAP_FAILED ) {
        bSuccess = false;
        close ( fd );
    }
    uio_mem_addr=(uint32_t *)virtual_base;
    return bSuccess;
}


jack_default_audio_sample_t AudioRegGet(unsigned int regaddr){
    int32_t value = 0;
    jack_default_audio_sample_t outval;
    value = (*(uint32_t *)(uio_mem_addr + regaddr));
    outval = (jack_default_audio_sample_t) value / 2147483647.0;
//    outval = (jack_default_audio_sample_t) value / 268435455.0;
//    outval = (jack_default_audio_sample_t) value / 1073741823.0;
   return outval;
}


/**
 * The process callback for this JACK application is called in a
 * special realtime thread once for each audio cycle.
 *
 * This client does nothing more than copy data from its input
 * port to its output port. It will exit when stopped by 
 * the user (e.g. using Ctrl-C on a unix-ish operating system)
 */
int
process (jack_nframes_t nframes, void *arg)
{
    int i;
//	jack_default_audio_sample_t *in_l, *in_r, *out_l, *out_r;
	jack_default_audio_sample_t *out_l, *out_r;
	
//	in_l = jack_port_get_buffer (input_port_l, nframes);
//	in_r = jack_port_get_buffer (input_port_r, nframes);
	out_l = jack_port_get_buffer (output_port_l, nframes);
	out_r = jack_port_get_buffer (output_port_r, nframes);

    for(i=0; i<nframes; i++) {
        out_l[i] = AudioRegGet(0);
        out_r[i] = AudioRegGet(1);
    }
    
//	memcpy (out_l, in_l,
//		sizeof (jack_default_audio_sample_t) * nframes);
//	memcpy (out_r, in_r,
//		sizeof (jack_default_audio_sample_t) * nframes);

	return 0;      
}

/**
 * JACK calls this shutdown_callback if the server ever shuts down or
 * decides to disconnect the client.
 */
void
jack_shutdown (void *arg)
{
	exit (1);
}

int
main (int argc, char *argv[])
{
	const char **ports;
	const char *client_name = "simple";
	const char *server_name = NULL;
	jack_options_t options = JackNullOption;
	jack_status_t status;
	

/* open uio device */
	if (!UioInit()) {
		fprintf (stderr, "cannot open uio device\n");
    }
    
    /* open a client connection to the JACK server */

	client = jack_client_open (client_name, options, &status, server_name);
	if (client == NULL) {
		fprintf (stderr, "jack_client_open() failed, "
			 "status = 0x%2.0x\n", status);
		if (status & JackServerFailed) {
			fprintf (stderr, "Unable to connect to JACK server\n");
		}
		exit (1);
	}
	if (status & JackServerStarted) {
		fprintf (stderr, "JACK server started\n");
	}
	if (status & JackNameNotUnique) {
		client_name = jack_get_client_name(client);
		fprintf (stderr, "unique name `%s' assigned\n", client_name);
	}

	/* tell the JACK server to call `process()' whenever
	   there is work to be done.
	*/

	jack_set_process_callback (client, process, 0);

	/* tell the JACK server to call `jack_shutdown()' if
	   it ever shuts down, either entirely, or if it
	   just decides to stop calling us.
	*/

	jack_on_shutdown (client, jack_shutdown, 0);

	/* display the current sample rate. 
	 */

	printf ("engine sample rate: %" PRIu32 "\n",
		jack_get_sample_rate (client));

	printf ("buffersize (nframes): %" PRIu32 "\n",
		jack_get_buffer_size (client));

	/* create four ports */

	input_port_l = jack_port_register (client, "input_l",
					 JACK_DEFAULT_AUDIO_TYPE,
					 JackPortIsInput, 0);
	input_port_r = jack_port_register (client, "input_r",
					 JACK_DEFAULT_AUDIO_TYPE,
					 JackPortIsInput, 0);
	output_port_l = jack_port_register (client, "output_l",
					  JACK_DEFAULT_AUDIO_TYPE,
					  JackPortIsOutput, 0);
	output_port_r = jack_port_register (client, "output_r",
					  JACK_DEFAULT_AUDIO_TYPE,
					  JackPortIsOutput, 0);

	if ((input_port_l == NULL) || (input_port_r == NULL) || (output_port_l == NULL) || (output_port_r == NULL)) {
		fprintf(stderr, "no more JACK ports available\n");
		exit (1);
	}

	/* Tell the JACK server that we are ready to roll.  Our
	 * process() callback will start running now. */

	if (jack_activate (client)) {
		fprintf (stderr, "cannot activate client");
		exit (1);
	}

	/* Connect the ports.  You can't do this before the client is
	 * activated, because we can't make connections to clients
	 * that aren't running.  Note the confusing (but necessary)
	 * orientation of the driver backend ports: playback ports are
	 * "input" to the backend, and capture ports are "output" from
	 * it.
	 */

	ports = jack_get_ports (client, NULL, NULL,
				JackPortIsPhysical|JackPortIsOutput);
	if (ports == NULL) {
		fprintf(stderr, "no physical capture ports\n");
		exit (1);
	}

	if (jack_connect (client, ports[0], jack_port_name (input_port_l))) {
		fprintf (stderr, "cannot connect left input ports\n");
	}

	if (jack_connect (client, ports[1], jack_port_name (input_port_r))) {
		fprintf (stderr, "cannot connect right input ports\n");
	}

	free (ports);
	
	ports = jack_get_ports (client, NULL, NULL,
				JackPortIsPhysical|JackPortIsInput);
	if (ports == NULL) {
		fprintf(stderr, "no physical playback ports\n");
		exit (1);
	}

	if (jack_connect (client, jack_port_name (output_port_l), ports[0])) {
		fprintf (stderr, "cannot connect left output ports\n");
	}
	
	if (jack_connect (client, jack_port_name (output_port_r), ports[1])) {
		fprintf (stderr, "cannot connect right output ports\n");
	}

	free (ports);
    /* keep running until stopped by the user */

	sleep (-1);

	/* this is never reached but if the program
	   had some other way to exit besides being killed,
	   they would be important to call.
	*/

	jack_client_close (client);
	exit (0);
}
