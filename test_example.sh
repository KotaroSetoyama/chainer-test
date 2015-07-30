#!/bin/sh -ex

cd chainer
python setup.py -q install

if [ -e cuda_deps/setup.py ]; then
  python cuda_deps/setup.py -q install
fi

apt-get install -y libjpeg-dev
pip install pillow

cd examples

# mnist
echo "Running mnist example"
cd mnist

# change epoch
sed -i -E "s/^n_epoch\s*=\s*[0-9]+/n_epoch = 1/" train_mnist.py
sed -i -E "s/^n_units\s*=\s*[0-9]+/n_units = 10/" train_mnist.py

python train_mnist.py
python train_mnist.py --gpu=0

cd ..

# ptb
echo "Running ptb example"
cd ptb

# change epoch
sed -i -E "s/^n_epoch\s*=\s*[0-9]+/n_epoch = 1/" train_ptb.py
sed -i -E "s/^n_units\s*=\s*[0-9]+/n_units = 10/" train_ptb.py
# change data size
sed -i -E "s/^train_data = (.*)/train_data = \1[:100]/" train_ptb.py
sed -i -E "s/^valid_data = (.*)/valid_data = \1[:100]/" train_ptb.py
sed -i -E "s/^test_data = (.*)/test_data = \1[:100]/" train_ptb.py

python download.py
python train_ptb.py
python train_ptb.py --gpu=0

cd ..

# sentiment
echo "Running sentiment example"
cd sentiment

# change epoch
sed -i -E "s/^n_epoch\s*=\s*[0-9]+/n_epoch = 1/" train_sentiment.py
# change data size
sed -i -E "s/^train_trees = (.*)/train_trees = \1[:10]/" train_sentiment.py
sed -i -E "s/^test_trees = (.*)/test_trees = \1[:10]/" train_sentiment.py

python download.py
python train_sentiment.py
python train_sentiment.py --gpu=0

cd ..

# imagenet
echo "Runnig imagenet example"
cd ../../data/imagenet

python ../../chainer/examples/imagenet/compute_mean.py data.txt
python ../../chainer/examples/imagenet/train_imagenet.py -a nin data.txt data.txt
python ../../chainer/examples/imagenet/train_imagenet.py -a alexbn data.txt data.txt
python ../../chainer/examples/imagenet/train_imagenet.py -a googlenet data.txt data.txt
python ../../chainer/examples/imagenet/train_imagenet.py -a googlenetbn data.txt data.txt

cd ../..
