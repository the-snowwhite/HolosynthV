#include <gtk/gtk.h>

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
bool AudioRegSet(unsigned int regadr, uint32_t value);

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
   return outval;
}


bool AudioRegSet(unsigned int regadr, uint32_t value){
    if (!m_bInitSuccess)
        return false;
    *((uint32_t *)(uio_mem_addr + regadr)) = value;
    return true;
}
/**
 * The process callback for this JACK application is called in a
 * special realtime thread once for each audio cycle.
 *
 * This client does nothing more than copy data from its input
 * port to its output port. It will exit when stopped by 
 * the user (e.g. using Ctrl-C on a unix-ish operating system)
 */
int process (jack_nframes_t nframes, void *arg)
{
    int i;
    bool success;
	jack_default_audio_sample_t *out_l, *out_r;
	
	out_l = jack_port_get_buffer (output_port_l, nframes);
	out_r = jack_port_get_buffer (output_port_r, nframes);

    success = AudioRegSet(2,1);
    
    for(i=0; i<nframes; i++) {
        out_l[i] = AudioRegGet(0);
        out_r[i] = AudioRegGet(1);
    }
    
    success = AudioRegSet(2,0);

	return 0;      
}
int bufferchange (jack_nframes_t nframes, void *arg)
{
    bool success;
    success = AudioRegSet(3,nframes);

	return 0;      
}

/**
 * JACK calls this shutdown_callback if the server ever shuts down or
 * decides to disconnect the client.
 */
void jack_shutdown (void *arg)
{
    bool success;
    success = AudioRegSet(3,0);
    exit (1);
}


void init_jack_client ()
{
	const char **ports;
	const char *client_name = "hsynth_audio";
	const char *server_name = NULL;
	jack_options_t options = JackNullOption;
	jack_status_t status;
    uint32_t buffersize;
    bool success;
	

/* open uio device */
    m_bInitSuccess = UioInit();

	if (!m_bInitSuccess) {
		g_printerr ( "cannot open uio device\n");
    }
    g_print ("uio init success\n"); 
    
    /* open a client connection to the JACK server */

	client = jack_client_open (client_name, options, &status, server_name);
    g_print ("after jack client open\n"); 

    if (client == NULL) {
		g_printerr ( "jack_client_open() failed, "
			 "status = 0x%2.0x\n", status);
		if (status & JackServerFailed) {
			g_printerr ( "Unable to connect to JACK server\n");
		}
		exit (1);
	}
	if (status & JackServerStarted) {
		g_printerr ( "JACK server started\n");
	}
	if (status & JackNameNotUnique) {
		client_name = jack_get_client_name(client);
		g_printerr ( "unique name `%s' assigned\n", client_name);
	}

	/* tell the JACK server to call `process()' whenever
	   there is work to be done.
	*/

	jack_set_process_callback (client, process, 0);
    g_print ("after jack callback process\n"); 

	jack_set_buffer_size_callback (client, bufferchange, 0);

    g_print ("after jack callback bufferchange\n"); 

	/* tell the JACK server to call `jack_shutdown()' if
	   it ever shuts down, either entirely, or if it
	   just decides to stop calling us.
	*/

	jack_on_shutdown (client, jack_shutdown, 0);

    g_print ("after jack on_shutdown\n"); 

	/* display the current sample rate. 
	 */

	g_print ("engine sample rate: %u\n",
		jack_get_sample_rate (client));

    buffersize = jack_get_buffer_size (client);
	g_print ("buffersize (nframes): %u\n",buffersize);
    
    success = AudioRegSet(3,buffersize);
	/* create four ports */
   
    g_print ("after AudioRegSet(3,buffersize)\n"); 

    output_port_l = jack_port_register (client, "output_l",
					  JACK_DEFAULT_AUDIO_TYPE,
					  JackPortIsOutput, 0);
	output_port_r = jack_port_register (client, "output_r",
					  JACK_DEFAULT_AUDIO_TYPE,
					  JackPortIsOutput, 0);

	if ((output_port_l == NULL) || (output_port_r == NULL)) {
		g_printerr ( "no more JACK ports available\n");
		exit (1);
	}

	/* Tell the JACK server that we are ready to roll.  Our
	 * process() callback will start running now. */

	if (jack_activate (client)) {
		g_printerr ( "cannot activate client");
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
				JackPortIsPhysical|JackPortIsInput);
	if (ports == NULL) {
		g_printerr ( "no physical playback ports\n");
		exit (1);
	}

	if (jack_connect (client, jack_port_name (output_port_l), ports[0])) {
		g_printerr ( "cannot connect left output ports\n");
	}
	
	if (jack_connect (client, jack_port_name (output_port_r), ports[1])) {
		g_printerr ( "cannot connect right output ports\n");
	}

	free (ports);
    /* keep running until stopped by the user */
    g_print ("at sleep point\n"); 

	//sleep (-1);
//	while (1) {}
//    getchar();
	/* this is never reached but if the program
	   had some other way to exit besides being killed,
	   they would be important to call.
	*/
//	exit (0);
}

static void close_jack_client (GtkApplication* app,
          gpointer        user_data) 
{
    bool success = AudioRegSet(3,0);
	
    jack_client_close (client);
}


static void activate (GtkApplication* app,
          gpointer        user_data)
{
    GtkWidget *window;
    GtkWidget *layout;
    GtkWidget *image;

    window = gtk_application_window_new (app);
    gtk_window_set_title (GTK_WINDOW (window), "Hsynth Audio");
    gtk_window_set_default_size (GTK_WINDOW (window), 300, 209);
    layout = gtk_layout_new(NULL, NULL);
    gtk_container_add(GTK_CONTAINER (window), layout);
    gtk_widget_show(layout);
    image = gtk_image_new_from_file("/home/holosynth/example-clients/Hsynth_ed_tiny.jpeg");
    gtk_layout_put(GTK_LAYOUT(layout), image, 0, 0);
    gtk_widget_show_all (window);
    init_jack_client();
}


int
main (int    argc,
      char **argv)
{
  GtkApplication *app;
  int status;

  app = gtk_application_new ("org.gtk.example", G_APPLICATION_FLAGS_NONE);
  g_signal_connect (app, "activate", G_CALLBACK (activate), NULL);
  g_signal_connect (app, "shutdown",G_CALLBACK (close_jack_client), NULL);
  status = g_application_run (G_APPLICATION (app), argc, argv);
  g_object_unref (app);

  return status;
}
