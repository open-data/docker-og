#!/usr/bin/env python3
import click
from ckanapi import LocalCKAN

from ckan.config.middleware import make_app
from ckan.cli import CKANConfigLoader

from ckanext.recombinant import helpers


@click.command()
@click.option('-c', '--config', required=True,
              default=None, type=click.File('r'),
              help='The CKAN configuration file path.')
@click.option('-d', '--dataset', default=None, required=True,
              help='The Dataset ID to create the resources on.')
def create_pd_combined_resources(config, dataset):
    click.echo('Bringing up CKAN instance from %s' % config.name)
    config = CKANConfigLoader(config.name).get_config()
    make_app(config)
    lc = LocalCKAN()
    for pkg_type in helpers.recombinant_get_types():
        geno = helpers.get_geno(pkg_type)
        for r in geno.get('resources', []):
            if 'published_resource_id' not in r:
                continue
            resource_id = r['published_resource_id']
            title = r['title'] if isinstance(r['title'], str) else r['title']['en']
            title += ' (%s)' % r['resource_name']
            try:
                lc.action.resource_create(
                    package_id=dataset,
                    id=resource_id,
                    name=title,
                    name_translated={'en': title, 'fr': title},
                    language=['en', 'fr'],
                    resource_type='dataset')
            except Exception as e:
                click.echo('Error creating resource %s: %s' % (resource_id, e))
                continue


if __name__ == '__main__':
    create_pd_combined_resources()
