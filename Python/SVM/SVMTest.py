import numpy as np
import matplotlib.pyplot as plt
from SVM import SVM
from sklearn import datasets

X, y = datasets.make_blobs(n_samples=200, n_features=2, centers=2, cluster_std=1.05, random_state=40)
y = np.where(y==0, -1, 1)

classifier = SVM()
classifier.fit(X,y)
print(classifier.w, classifier.b)

def SVM_plot():
        def get_hp_value(x, w, b, offset):
            return (-w[0] * x + b + offset) / w[1]

        fig = plt.figure()
        ax = fig.add_subplot(1, 1, 1)
        plt.scatter(X[:, 0], X[:, 1], marker="o", c=y)

        x0_1 = np.amin(X[:, 0])
        x0_2 = np.amax(X[:, 0])

        x1_1 = get_hp_value(x0_1, classifier.w, classifier.b, 0)
        x1_2 = get_hp_value(x0_2, classifier.w, classifier.b, 0)

        x1_1_m = get_hp_value(x0_1, classifier.w, classifier.b, -1)
        x1_2_m = get_hp_value(x0_2, classifier.w, classifier.b, -1)

        x1_1_p = get_hp_value(x0_1, classifier.w, classifier.b, 1)
        x1_2_p = get_hp_value(x0_2, classifier.w, classifier.b, 1)

        ax.plot([x0_1, x0_2], [x1_1, x1_2], "r--") # This is the Hyperplane
        ax.plot([x0_1, x0_2], [x1_1_m, x1_2_m], "k")
        ax.plot([x0_1, x0_2], [x1_1_p, x1_2_p], "k")

        x1_min = np.amin(X[:, 1])
        x1_max = np.amax(X[:, 1])
        ax.set_ylim([x1_min - 3, x1_max + 3])

        plt.show()

SVM_plot()
