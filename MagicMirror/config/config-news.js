/* Magic Mirror Config
 *
 * By Michael Teeuw http://michaelteeuw.nl
 * Modified by Ron Record http://ronrecord.com
 * MIT Licensed.
 *
 * For more information how you can configurate this file
 * See https://github.com/MichMich/MagicMirror#configuration
 *
 */

var config = {
//	address: "localhost",
	address: "0.0.0.0", // Address to listen on, can be:
	                      // - "localhost", "127.0.0.1", "::1" to listen on loopback interface
	                      // - another specific IPv4/6 to listen on a specific interface
	                      // - "", "0.0.0.0", "::" to listen on any interface
	                      // Default, when address config is left out, is "localhost"
	port: 8080,
    // Set [] to allow all IP addresses
	// or add a specific IPv4 of 192.168.1.5 :
	// ["127.0.0.1", "::ffff:127.0.0.1", "::1", "::ffff:192.168.1.5"],
	// or IPv4 range of 192.168.3.0 --> 192.168.3.15 use CIDR format :
	// ["127.0.0.1", "::ffff:127.0.0.1", "::1", "::ffff:192.168.3.0/28"],
	ipWhitelist: [
        "127.0.0.1",
        "10.0.1.44", // Mac Mini
        "10.0.1.51", // Mac Pro
        "10.0.1.67", // Raspberry Pi MagicMirror
        "10.0.1.69", // iPad Air
        "10.0.1.76", // iPhone Max Xs
        "::ffff:127.0.0.1",
        "::1",
    //  "::ffff:10.0.1.0/26",
    //  "::ffff:10.0.1.64/27",
    //  "::ffff:10.0.1.96/30"
    ],

	language: "en",
	timeFormat: 12,
	units: "imperial",
	// serverOnly:  true/false/"local" ,
			     // local for armv6l processors, default 
			     //   starts serveronly and then starts chrome browser
			     // false, default for all  NON-armv6l devices
			     // true, force serveronly mode, because you want to.. no UI on this device
	
	modules: [
		{
			module: "alert",
		},
		{
			module: "updatenotification",
			position: "top_bar"
		},
        {
            module: 'MMM-Remote-Control',
        },
        {
            module: "MMM-COVID-19",
            header: "Coronavirus Daily Update",
            position: "bottom_bar",
            config: {
              scanInterval: 1000 * 60 * 60 * 12,
              rotateInterval: 1000 * 5,
              detailProvince: true,
//            pinned: ["Mainland China", null],
//            pinned: ["Others", "Diamond Princess cruise ship"],
//            pinned: ["US", "Santa Clara, CA"],
              pinned: ["US"],
              logProvinceCountry: false,
              logOnce: true,
              sortOrder: null,
            }
        },
        {
            module: "newsfeed",
            position: "top_bar",
            config: {
                feeds: [
                    {
                        title: "New York Times",
                        url: "http://www.nytimes.com/services/xml/rss/nyt/HomePage.xml"
                    },
                    {
                        title: "Washington Post",
                        url: "http://feeds.washingtonpost.com/rss/national"
                    },
                    {
                        title: "Mercury News",
                        url: "https://www.mercurynews.com/feed"
                    },
                    {
                        title: "Centers for Disease Control",
                        url: "https://tools.cdc.gov/api/v2/resources/media/403372.rss"
                    },
                    {
                        title: "World Health Organization",
                        url: "https://www.who.int/feeds/entity/csr/don/en/rss.xml"
                    },
                ],
                showSourceTitle: true,
                showPublishDate: true,
                broadcastNewsFeeds: true,
                broadcastNewsUpdates: true
            }
        },
        {
            module: "MMM-News",
            position: "top_center",
            config: {
              apiKey : "xxxxxxx_newsapi.org_xxxxxxxxxxx",
              type: "vertical",
              touchable: false,
              telegramBotOrderOpenDetail : true,
              query : [
                {
                  sources: "abc-news, bbc-news, cnn, google-news",
                },
                {
                  country: "us",
                  category: "general",
                },
                {
                  country: "uk",
                  category: "general",
                }
              ],
            }
        },
//      {
//          module: "MMM-Volume",
//          position: "top_left", // It is meaningless. but you should set.
//          config: {
//            usePresetScript: "ALSA", // "ALSA" is supported by default.
//            volumeOnStart: 50,
//          }
//      },
        {
            module: 'MMM-TelegramBot',
            config: {
              telegramAPIKey : 'xxxxxx_Your-Telegram-API-Key_xxxxxxxxxxxxxxxxx',
              // This is NOT the username of bot.
              allowedUser : ['Your-Telegram-Username'],
              adminChatId : Your-Telegram-Chat-ID,
              useWelcomeMessage: true,
              verbose: false,
              favourites:["/hideall", "/showall", "/screenshot", "/shutdown"],
              screenshotScript: "scrot",
              detailOption: {},
              customCommands: [],
//            customCommands: [
//              {
//                command: "test",
//                callback: (command, handler) => {
//                  handler.reply("TEXT", "This is test command!")
//                }
//              },
//              {
//                command: "detailnews",
//                description: "For detail of current news article"
//                callback: (command, handler, self) => {
//                  self.sendNotification("ARTICLE_MORE_DETAILS")
//                  handler.reply("TEXT", "Yes, sir!")
//                }
//              },
//            ],
            }
        },
	]
};

/*************** DO NOT EDIT THE LINE BELOW ***************/
if (typeof module !== "undefined") {module.exports = config;}