import setuptools

version = '1.0.0'

setuptools.setup(
    name='rpco-hacking-checks',
    author='Rackspace Private Cloud',
    description='Hacking/Flake8 checks for rpc-openstack',
    version=version,
    install_requires=['hacking'],
    classifiers=[
        'Development Status :: 5 - Production/Stable',
        'Intended Audience :: Developers',
    ],
    py_modules=['rpco_checks'],
    provides=['rpco_checks'],
    entry_points={
        'flake8.extension': [
            'rpco.git_title_bug = rpco_checks:OnceGitCheckCommitTitleBug',
            ('rpco.git_title_length = '
             'rpco_checks:OnceGitCheckCommitTitleLength'),
            ('rpco.git_title_period = '
             'rpco_checks:OnceGitCheckCommitTitlePeriodEnding'),
        ]
    },
)
