/*
 * socmidi -- SoC midi for Terasic DE1-SoC board
 * Author: B. Steinsbo <bsteinsbo@gmail.com>
 *
 * Based on sam9g20_wm8731 by
 * Sedji Gaouaou <sedji.gaouaou@atmel.com>
 *
 * Licensed under the GPL-2.
 */

#include <linux/init.h>
#include <linux/wait.h>
#include <linux/err.h>
#include <linux/platform_device.h>
#include <linux/of.h>
#include <linux/module.h>
#include <linux/uaccess.h>
#include <linux/ioport.h>
#include <linux/io.h>

#define MIDIREG_BASE 0xff200000
#define MIDIREG_SIZE PAGE_SIZE
#define MIDIREG_OFFSET 0x50000

#include <sound/core.h>
#include <sound/seq_kernel.h>
#include <sound/rawmidi.h>
#include <sound/initval.h>

#define ins 0
#define outs 1
#define MAX_MIDI_DEVICES       4

#define SND_SOCMIDI_DRIVER     "snd_socmidi"

static int index[SNDRV_CARDS] = SNDRV_DEFAULT_IDX;     /* Index 0-MAX */
static char *id[SNDRV_CARDS] = SNDRV_DEFAULT_STR;      /* ID for this card */
static bool enable[SNDRV_CARDS] = {1, [1 ... (SNDRV_CARDS - 1)] = 0};
static int midi_devs[SNDRV_CARDS] = {[0 ... (SNDRV_CARDS - 1)] = 4};

void *midireg_mem;

struct snd_card_virsound {
       struct snd_card *card;
       struct snd_rawmidi *midi[MAX_MIDI_DEVICES];
};

static struct platform_device *devices[SNDRV_CARDS];

//int index = substream->number;

/*
static int soc_hw_params(struct snd_pcm_substream *substream,
       struct snd_pcm_hw_params *params)
{
       struct device *dev = rtd->card->dev;

       return 0;
}
*/
static void snd_socmidi_transmit(unsigned char data);
static void snd_socmidi_output_trigger(struct snd_rawmidi_substream *substream, int);
static int snd_socmidi_open(struct snd_rawmidi_substream *substream);
static int snd_socmidi_close(struct snd_rawmidi_substream *substream);
static void snd_virsound_unregister_all(void);
static int __init alsa_card_virsound_init(void);
static void __exit alsa_card_virsound_exit(void);

//

static void snd_socmidi_transmit(unsigned char data){

       iowrite8(data, midireg_mem);

}

static void snd_socmidi_output_trigger(struct snd_rawmidi_substream *substream, int up) {
//unsigned char data;
/*
    while (snd_rawmidi_transmit_peek(substream, &data, 1) == 1) {
        if (snd_mychip_try_to_transmit(data))
            snd_rawmidi_transmit_ack(substream, 1);
        else
        break; // hardware FIFO full //
    }
*/

//    while (snd_mychip_transmit_possible()) {
    while (1) {
        unsigned char data;
        if (snd_rawmidi_transmit(substream, &data, 1) != 1)
            break; /* no more data */
        snd_socmidi_transmit(data);
    }


}

static int snd_socmidi_open(struct snd_rawmidi_substream *substream)
{
       return 0;
}

static int snd_socmidi_close(struct snd_rawmidi_substream *substream)
{
       return 0;
}

static struct snd_rawmidi_ops snd_socmidi_output = {
    .open = snd_socmidi_open,
    .close = snd_socmidi_close,
    .trigger = snd_socmidi_output_trigger,
};


static int soc_midi_probe(struct platform_device *devptr)
{
       struct snd_card *card;
       struct snd_card_virsound *vsound;

    struct snd_rawmidi *rmidi;
    struct snd_virsound_dev *rdev;
    struct snd_rawmidi_substream *substream;

    struct resource *res;

    int idx, err;
       int dev = devptr->id;


       err = snd_card_new(&devptr->dev, index[dev], id[dev], THIS_MODULE,
                          sizeof(struct snd_card_virsound), &card);
       if (err < 0)
               return err;
       vsound = card->private_data;
       vsound->card = card;

       if (midi_devs[dev] > MAX_MIDI_DEVICES) {
               snd_printk(KERN_WARNING
                          "too much midi devices for virsound %d: force to use %d\n",
                          dev, MAX_MIDI_DEVICES);
               midi_devs[dev] = MAX_MIDI_DEVICES;
       }

    err = snd_rawmidi_new(card, "SocMIDI", 0, outs, ins, &rmidi);
               if (err < 0)
                       goto __nodev;
    rdev = rmidi->private_data;
    idx = 0;
    vsound->midi[idx] = rmidi;

    strcpy(rmidi->name, "Soc MIDI");
       strcpy(card->driver, "SocMIDI");
       strcpy(card->shortname, "SocMIDI");
       sprintf(card->longname, "Soc MIDI Card %i", dev + 1);

    rmidi->info_flags = SNDRV_RAWMIDI_INFO_OUTPUT;
    // rmidi->info_flags = SNDRV_RAWMIDI_INFO_OUTPUT |
    //                     SNDRV_RAWMIDI_INFO_INPUT |
    //                     SNDRV_RAWMIDI_INFO_DUPLEX;


    snd_rawmidi_set_ops(rmidi, SNDRV_RAWMIDI_STREAM_OUTPUT, &snd_socmidi_output);
//    snd_rawmidi_set_ops(rmidi, SNDRV_RAWMIDI_STREAM_INPUT, &snd_socmidi_input_ops);


       /* name substreams */
       /* output */
    list_for_each_entry(substream,
                           &rmidi->streams[SNDRV_RAWMIDI_STREAM_OUTPUT].substreams,
                           list) {
               sprintf(substream->name,
                       "Soc MIDI Port %d", substream->number+1);
       }


       res = request_mem_region((MIDIREG_BASE + MIDIREG_OFFSET), MIDIREG_SIZE, "MIDIREG");
       if (res == NULL) {
               return -EBUSY;
       }

       midireg_mem = ioremap((MIDIREG_BASE + MIDIREG_OFFSET), MIDIREG_SIZE);
       if (midireg_mem == NULL) {
               release_mem_region(MIDIREG_BASE, MIDIREG_SIZE);
               return -EFAULT;
       }

/*
       for (idx = 0; idx < midi_devs[dev]; idx++) {
               struct snd_rawmidi *rmidi;
               struct snd_virsound_dev *rdev;

               err = snd_virsound_new(card, idx, &rmidi);
               if (err < 0)
                       goto __nodev;
               rdev = rmidi->private_data;
               vsound->midi[idx] = rmidi;
               strcpy(rmidi->name, "Soc Raw MIDI");
               rdev->seq_mode = SNDRV_VIRMIDI_SEQ_DISPATCH;
       }
*/
       strcpy(card->driver, "SocMIDI");
       strcpy(card->shortname, "SocMIDI");
       sprintf(card->longname, "Soc MIDI Card %i", dev + 1);

       err = snd_card_register(card);
       if (!err) {
               platform_set_drvdata(devptr, card);
               return 0;
       }
__nodev:
       snd_card_free(card);
       return err;
}

static int soc_midi_remove(struct platform_device *devptr)
{
       snd_card_free(platform_get_drvdata(devptr));
       return 0;
}

static const struct of_device_id soc_midi_dt_ids[] = {
       { .compatible = "socmidi", },
       { }
};
MODULE_DEVICE_TABLE(of, soc_midi_dt_ids);

static struct platform_driver snd_socmidi_driver = {
       .driver = {
               .name   = SND_SOCMIDI_DRIVER,
               .owner  = THIS_MODULE,
               .of_match_table = of_match_ptr(soc_midi_dt_ids),
       },
       .probe  = soc_midi_probe,
       .remove = soc_midi_remove,
};

static void snd_virsound_unregister_all(void)
{
       int i;

       for (i = 0; i < ARRAY_SIZE(devices); ++i)
               platform_device_unregister(devices[i]);
       platform_driver_unregister(&snd_socmidi_driver);
}

static int __init alsa_card_virsound_init(void)
{
       int i, cards, err;

       err = platform_driver_register(&snd_socmidi_driver);
       if (err < 0)
               return err;

       cards = 0;
       for (i = 0; i < SNDRV_CARDS; i++) {
               struct platform_device *device;

               if (!enable[i])
                       continue;
               device = platform_device_register_simple(SND_SOCMIDI_DRIVER,
                                                        i, NULL, 0);
               if (IS_ERR(device))
                       continue;
               if (!platform_get_drvdata(device)) {
                       platform_device_unregister(device);
                       continue;
               }
               devices[i] = device;
               cards++;
       }
       if (!cards) {
#ifdef MODULE
               printk(KERN_ERR "Card-VirMIDI soundcard not found or device busy\n");
#endif
               snd_virsound_unregister_all();
               return -ENODEV;
       }
       return 0;
}


static void __exit alsa_card_virsound_exit(void)
{
       snd_virsound_unregister_all();
}

/* Module information */
MODULE_AUTHOR("Bjarne Steinsbo <bsteinsbo@gmail.com>");
MODULE_DESCRIPTION("ALSA SoC DE1-SoC_-midi");
MODULE_LICENSE("GPL");

//module_platform_driver(snd_socmidi_driver);
module_init(alsa_card_virsound_init)
module_exit(alsa_card_virsound_exit)
