import requests
import re
from os import path
from bs4 import BeautifulSoup

BASE_PATH = path.dirname(__file__)
BASE_URL = 'https://www.dapenti.com/blog/'
LIST_URL = '%sblog.asp?name=xilei&subjectid=70' % BASE_URL
ARTICLE_URL_PATTERN = 'more\.asp\?name=xilei&id=\d+'
ARTICLE_TITLE_PATTERN = '喷嚏图卦\s*(\d{8})'


def get_page(url):
    response = requests.get(url)
    if response.status_code != 200:
        raise Exception('Failed to fetch page: %s' % url)
    return BeautifulSoup(response.content, 'lxml', from_encoding='gb2312')


def find_articles():
    list_page = get_page(LIST_URL)

    links = list_page.find('td', class_='oblog_t_2').find_all('a')
    links = [link for link in links if re.match(ARTICLE_URL_PATTERN, link['href']) and re.search(ARTICLE_TITLE_PATTERN, link.text)]

    articles = []
    for link in links:
        found = re.search(ARTICLE_TITLE_PATTERN, link.text)
        if not found:
            continue

        date = found.group(1)
        date = [date[0:4], date[4:6], date[6:]]

        post_file = path.join(BASE_PATH, 'jekyll', '_posts', date[0], '%s-%s-%s-%s.html' % (date[0], date[1], date[2], ''.join(date)))

        if not path.isfile(post_file):
            articles.append({
                'title': link.text,
                'url': BASE_URL + link['href'],
                'date': date,
                'file': post_file
            })

    return articles


def collect_article(article):
    html = get_page(article['url'])
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

    with open(article['file'], 'w') as f:
        f.write(post_contents)


def main():
    articles = find_articles()
    for article in articles:
        collect_article(article)


if __name__ == '__main__':
    main()
