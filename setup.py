from setuptools import setup, find_packages

setup(
    name='Genius Bryson',
    version='1.0.0',
    author='Bryson Omullo',
    author_email='bnyaliti@gmail.com',
    description='Automated Forex Chart Analysis Assistant for MetaTrader 5',
    packages=find_packages(),
    install_requires=[
        # List any required libraries or dependencies here
        # For example:
        # 'numpy',
        # 'pandas',
        # 'matplotlib',
    ],
    classifiers=[
        'Programming Language :: Python :: 3',
        'License :: OSI Approved :: MIT License',
        'Operating System :: OS Independent',
    ],
    python_requires='>=3.6',
)
