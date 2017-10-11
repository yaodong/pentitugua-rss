from bs4 import BeautifulSoup
from glob import glob
from os import path, makedirs
from rfeed import Feed, Item, Guid
import shutil
import re
import requests
import yaml
import click

BASE_PATH = path.dirname(__file__)
BUILD_PATH = '/srv/gh-pages'
BASE_URL = 'https://www.dapenti.com/blog/'
LIST_URL = '%sblog.asp?name=xilei&subjectid=70' % BASE_URL
ARTICLE_URL_PATTERN = 'more\.asp\?name=xilei&id=\d+'
ARTICLE_TITLE_PATTERN = '喷嚏图卦\s*(\d{8})'
JEKYLL_POSTS_DIR = path.join(BASE_PATH, 'jekyll', '_posts')
RESPONSE_ENCODING = 'gbk'


def get_url(url):
    response = requests.get(url)
    if response.status_code != 200:
        raise Exception('Failed to fetch page: %s' % url)
    response.encoding = RESPONSE_ENCODING

    return BeautifulSoup(response.text, 'html.parser')


def find_available_articles():
    list_page = get_url(LIST_URL)

    links = list_page.find('td', class_='oblog_t_2').find_all('a')
    links = [link for link in links if
             re.match(ARTICLE_URL_PATTERN, link['href']) and re.search(ARTICLE_TITLE_PATTERN, link.text)]

    articles = []
    for link in links:
        found = re.search(ARTICLE_TITLE_PATTERN, link.text)
        if not found:
            continue

        date_string = found.group(1)
        date = [date_string[0:4], date_string[4:6], date_string[6:]]
        data_file = path.join(BASE_PATH, 'posts', '%s/%s/%s.html' % (date[0], date[1], date[2]))

        if not path.isfile(data_file):
            articles.append({
                'title': link.text,
                'url': BASE_URL + link['href'],
                'date': date,
                'file': data_file
            })

    return articles


def download_article(article):
    html = get_url(article['url'])
    content = html.find('div', class_='oblog_text')

    publish_time = '00:00:00'
    for segment in html.find_all('span', class_='oblog_text'):
        matches = re.search('发布于\s*(\d+)-(\d+)-(\d+)\s+([\d:]+)', segment.decode())
        if matches:
            publish_time = matches.group(4)
            break

    front_matters = [
        '---',
        'layout: post',
        'title: %s' % article['title'],
        'date: %s %s' % ('-'.join(article['date']), publish_time),
        'link: %s' % article['url'],
        '---'
    ]

    post_contents = '\n'.join(front_matters) + '\n\n' + content.decode().replace('\r\n', '\n')

    post_dir = path.dirname(article['file'])
    if not path.isdir(post_dir):
        makedirs(post_dir)
    with open(article['file'], 'w') as f:
        f.write(post_contents)


def generate_feed():
    if path.isdir(JEKYLL_POSTS_DIR):
        shutil.rmtree(JEKYLL_POSTS_DIR)

    files = sorted(glob('posts/*/*/*.html'))[-3:]
    feed_items = []
    for file in files:
        post_data = read_data(file)
        feed_items.append(Item(
            title=post_data['front_matters']['title'],
            link=post_data['front_matters']['link'],
            description=post_data['content'],
            author='喷嚏网',
            guid=Guid(post_data['front_matters']['link']),
            pubDate=post_data['front_matters']['date']
        ))

    feed_items.reverse()
    feed = Feed(
        title="喷嚏图卦",
        link="http://www.pentitugua.com/rss.xml",
        description="【喷嚏图卦】喷嚏网(www.dapenti.com)-阅读、发现和分享：8小时外的健康生活！",
        language="zh-CN",
        lastBuildDate=feed_items[0].pubDate,
        items=feed_items)

    rss = feed.rss()
    # force order attributes
    rss = re.sub('<rss[^>]+>', '<rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/">', rss)

    with open(path.join(BUILD_PATH, 'rss.xml'), 'w') as f:
        f.write(rss)

    for file in ['index.html', 'CNAME']:
        shutil.copy(path.join(BASE_PATH, 'templates', file), path.join(BUILD_PATH, file))


def read_data(file):
    with open(path.join(BASE_PATH, file)) as f:
        matches = re.match('(?sm)^---(?P<meta>.*?)^---(?P<body>.*)', f.read())
        front_matters = yaml.load(matches.group(1))
        content = matches.group(2)

    return {
        'front_matters': front_matters,
        'content': content
    }


@click.group()
def cli():
    pass


@cli.command()
def download():
    for article in find_available_articles():
        download_article(article)


@cli.command()
def build():
    generate_feed()


if __name__ == '__main__':
    cli()
