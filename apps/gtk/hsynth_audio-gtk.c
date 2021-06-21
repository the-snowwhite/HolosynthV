#include <gtk/gtk.h>

#include <dirent.h> 
#include <stdio.h>
#include <errno.h>
#include <unistd.h>
#include <assert.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <stdint.h>
#include <fcntl.h>
#include <sys/mman.h>

#include <jack/jack.h>
#include <jack/midiport.h>

jack_port_t *output_port_l;
jack_port_t *output_port_r;
jack_client_t *client;
jack_port_t *input_port;

#define HW_REGS_SPAN ( 4096 )

bool m_bInitSuccess;
int fd;
void *virtual_base;
uint32_t *uio_mem_addr=NULL;

bool UioInit();
jack_default_audio_sample_t AudioRegGet(unsigned int regadr);
bool AudioRegSet(unsigned int regadr, uint32_t value);

static jack_port_t* port;

bool UioInit()
{
    bool bSuccess = true;
    // Open /dev/uiox
    char buf[1024],str[32], uio_dev[16];
    ssize_t len;
    DIR *d;
    struct dirent *dir;
    d = opendir("/sys/class/uio");
    if (d) {
            while ((dir = readdir(d)) != NULL) {
            if( dir->d_type == DT_LNK) {
                sprintf(str, "/sys/class/uio/%s", dir->d_name);

                if ((len = readlink(str, buf, sizeof(buf)-1)) != -1){
                    buf[len] = '\0';
                }
                if(strstr(buf,"a0020000.hm2_axilite_int") != NULL) {
                    g_print("\n Found string in %s\n", dir->d_name);
                    sprintf(uio_dev, "/dev/%s\0", dir->d_name);
                    g_print("%s\n\n", buf);
                    g_print("%s\n", uio_dev);
                }
            }
        }
        closedir(d);
    }

    
    if ( ( fd = open ( uio_dev, ( O_RDWR | O_SYNC ) ) ) == -1 ) {
        bSuccess = false;
        close ( fd );
    }
    if (!bSuccess) {
        g_printerr ( "cannot open uio device\n");
    } else {
        g_print ("uio open success\n"); 
    }

    virtual_base = mmap( NULL, HW_REGS_SPAN, ( PROT_READ | PROT_WRITE ), MAP_SHARED, fd, 0);

    if ( virtual_base == MAP_FAILED ) {
        bSuccess = false;
        close ( fd );
    }
    if (!bSuccess) {
        g_printerr ( "uio mmap failed\n");
    } else {
        g_print ("uio mmap success\n"); 
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
    int i,j;
    bool success;
    jack_default_audio_sample_t *out_l, *out_r;

    void* port_buf;
/*    jack_midi_event_t in_event;
    jack_nframes_t event_index;
    
    port_buf = jack_port_get_buffer(input_port, nframes);
    assert (port_buf);
    event_index = jack_midi_get_event_count(port_buf);

    for (i = 0; i < event_index; ++i) {
        jack_midi_event_t event;
        int r;

        r = jack_midi_event_get (&event, port_buf, i);
        if (r == 0) {
            size_t j;
            for (j = 0; j < event.size; ++j) {
                AudioRegSet(5, event.buffer[j]);
            }
        }
    }
*/
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


jack_client_t*  init_jack_client ()
{
    const char **ports;
    const char *client_name = "hsynth_audio";
    const char *server_name = NULL;
    jack_options_t options = JackNullOption;
    jack_status_t status;
    jack_client_t* client;
    uint32_t buffersize;
    uint32_t samplerate;
    bool success;
    

/* open uio device */
    m_bInitSuccess = UioInit();

    if (!m_bInitSuccess) {
        g_printerr ( "cannot open uio device\n");
    } else {
        g_print ("uio init success\n"); 
    }
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

    samplerate = jack_get_sample_rate (client);
    g_print ("engine sample rate: %u\n",
        samplerate);

    buffersize = jack_get_buffer_size (client);
    g_print ("buffersize (nframes): %u\n",buffersize);
    
//    success = AudioRegSet(4,samplerate);
//    success = AudioRegSet(3,buffersize);

/* create two ports */

//    g_print ("after AudioRegSet(3,buffersize)\n"); 

    output_port_l = jack_port_register (client, "output_l",
                    JACK_DEFAULT_AUDIO_TYPE,
                    JackPortIsOutput, 0);
    output_port_r = jack_port_register (client, "output_r",
                    JACK_DEFAULT_AUDIO_TYPE,
                    JackPortIsOutput, 0);
/*    
    input_port = jack_port_register (client, "midi_in",
                    JACK_DEFAULT_MIDI_TYPE,
                    JackPortIsInput, 0);
*/
//    if ((output_port_l == NULL) || (output_port_r == NULL) || input_port == NULL)
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

    return (client);
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
    GtkWidget *label;
    GtkWidget *box;
    
    char msg[32]={0};
    int samplerate;
    jack_client_t* client;

    window = gtk_application_window_new (app);
    
    gtk_window_set_title (GTK_WINDOW (window), "Hsynth Audio");
    gtk_window_set_default_size (GTK_WINDOW (window), 300, 255);
    layout = gtk_layout_new(NULL, NULL);
    gtk_container_add(GTK_CONTAINER (window), layout);
    
    gtk_widget_show(layout);

    image = gtk_image_new_from_file("./Hsynth_ed_tiny.jpeg");
    gtk_layout_put(GTK_LAYOUT(layout), image, 0, 0);
    
    client = init_jack_client();
    samplerate = jack_get_sample_rate (client);
    
    g_snprintf(msg, sizeof msg, "Samplerate is \n%d Hz", samplerate);
    label = gtk_label_new(msg);

    gtk_layout_put(GTK_LAYOUT(layout), label, 0, 190);
    
    
    gtk_widget_show_all (window);
}


int main (int argc, char **argv)
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
