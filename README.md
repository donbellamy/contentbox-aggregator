# ContentBox Aggregator Module

This module allows you to automatically import RSS feeds as content items and display them in your ContentBox site.

## Requirements

Built and tested with:

- ColdBox 5.6.2+
- ContentBox 4.2.1+
- Lucee 5.2.3.35+
- MySQL 8.0+

## Future release
- Support for ContenBox 5 and ColdBox 6

## Installation

1. Stop the server running your [ContentBox](https://www.ortussolutions.com/products/contentbox) site.
2. Install using [CommandBox](https://www.ortussolutions.com/products/commandbox) by typing `box install contentbox-aggregator`.
3. Run the mysql.sql script located in /sql on your [ContentBox](https://www.ortussolutions.com/products/contentbox) database.
4. Copy the files located in /themes/default into your current theme folder.  If you are not using the default theme, you will need to modify these files to match your current theme.
5. Start up your server running [ContentBox](https://www.ortussolutions.com/products/contentbox).
6. Activate the module in the admin and begin using.

## Sites using ContentBox Aggregator

- [Prepping.com](https://prepping.com) - Proof of concept site pulling prepping and survival articles from over 100 different rss feeds.

## License

Apache License, Version 2.0.
