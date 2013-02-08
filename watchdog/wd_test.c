/*
 * Copyright (C) 2009 Ericsson AB
 * License terms: GNU General Public License (GPL) version 2
 *
 * Author:   2008, Linus Walleij <linus.walleij@stericsson.com>
 * Modified: 2009, Martin Persson <martin.persson@stericsson.com>
 */

/* Standard Include Files */
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <unistd.h>
#include <linux/types.h>
#include <linux/watchdog.h>
#include <sys/time.h>
#include <fcntl.h>

/***************************************************************
 * setup() - performs all ONE TIME setup for this test.
 ***************************************************************/
void setup(int *wd_fd)
{
	int fd = 0;
	char *device = "/dev/" WD_NAME;

	DBG_PRINT(printf("[%s]\n", __func__));

	TEST(fd = open(device, O_RDWR));

	if (TEST_RETURN == -1) {
		tst_resm(TBROK,
			 "Failed to open %s, errno=%d : %s",
			 device, TEST_ERRNO, strerror(TEST_ERRNO));
		TEST_CLEANUP;
		tst_exit();
	}

	*wd_fd = fd;
}

void enable(int fd)
{
	unsigned long dummy = WDIOS_ENABLECARD;
	DBG_PRINT(printf("[%s]\n", __func__));
	TEST_TFAIL(ioctl(fd, WDIOC_SETOPTIONS, &dummy));
}

void disable(int fd)
{
	unsigned long dummy = WDIOS_DISABLECARD;
	DBG_PRINT(printf("[%s]\n", __func__));
	TEST_TFAIL(ioctl(fd, WDIOC_SETOPTIONS, &dummy));
}

int time_left(int fd, unsigned long *arg)
{
	DBG_PRINT(printf("[%s]\n", __func__));
	TEST_TFAIL(ioctl(fd, WDIOC_GETTIMELEFT, arg));
	return TEST_RETURN;
}

void monitor(int fd, int start_val, int how_long)
{
	int i, a, b, retval;
	unsigned long time;

	DBG_PRINT(printf("[%s]\n", __func__));

	for (i = 0; i < how_long; i++) {
		sleep(1);

		TEST_TFAIL(time_left(fd, &time));

		a = start_val - (i + 1);
		b = start_val - (i + 2);
		if (time > a || time < b) {
			tst_resm(TFAIL, __FILE__, __LINE__,
				 "File: %s Line: %d. Unexpected time left: %d. Should be [%d..%d]\n",
				 time, a, b);
		}
	}
}

void reset(int fd, unsigned long value)
{
	DBG_PRINT(printf("[%s]\n", __func__));
	TEST_TFAIL(ioctl(fd, WDIOC_SETTIMEOUT, &value));
}

void feed(int fd)
{
	unsigned long dummy;
	DBG_PRINT(printf("[%s]\n", __func__));
	TEST_TFAIL(ioctl(fd, WDIOC_KEEPALIVE, &dummy));
}

int main(int argc, char **argv)
{

	int lc;			/* loop counter */
	char *msg;		/* message returned from parse_opts */
	int fd = 0;

	DBG_PRINT(printf("[%s]\n", __func__));

	/***************************************************************
	 * parse standard options
	 ***************************************************************/
	if ((msg =
	     parse_opts(argc, argv, (option_t *) NULL,
			NULL)) != (char *) NULL) {
		tst_brkm(TBROK, NULL, "OPTION PARSING ERROR - %s", msg);
		tst_exit();
	}

	setup(&fd);

	/***************************************************************
	 * check looping state if -c option given
	 ***************************************************************/
	for (lc = 0; TEST_LOOPING(lc); lc++) {

		/* reset Tst_count in case we are looping. */
		for (Tst_count = 0; Tst_count < TST_TOTAL; Tst_count++) {

			/***************************************************************
			 * only perform functional verification if flag set (-f not given)
			 ***************************************************************/
			if (STD_FUNCTIONAL_TEST) {

				disable(fd);
				enable(fd);

				/* default timeout is 60 seconds */
				printf("This test will take about 25s\n");
				monitor(fd, 60, 10);

				reset(fd, 10);
				monitor(fd, 10, 5);

				feed(fd);
				monitor(fd, 10, 5);

				reset(fd, 5);
				disable(fd);
				sleep(6);

				/* default timeout is 60 seconds */
				reset(fd, 60);
				enable(fd);

				printf("Let watchdog reboot ME in 5 seconds");
				reset(fd, 5);

				monitor(fd, 5, 5);

				tst_resm(TFAIL, "Watchdog should have rebooted the system, ie somethings wrong\n");

			}
		}
	}

	if (TEST_RETURN >= 0)
		tst_resm(TPASS,
			 "Functional test for watchdog; Ericsson AB COH 901 327 IP core OK\n");
	cleanup(fd);
	tst_exit();
	return 0;
}
