# Support Vector Machine(SVM) is an algorithm where a linear model 
# is used to find a hyperplane that best separates the data.
# The best hyperplane is the one that represents the largest separation
# between the two classes.
# The hyperplane used must satisfied the conditions below
# Wx - b = 0 and y(Wx - b) >= 1 where W = weights, b = Bias and y is the class.
# A cost function is used to determine the weights and bias. 
# loss = lambda*magnitude(W) + 1/n * sum(max(0, 1 - y(Wx - b))) called the Hinge Loss
#      = lambda*magnitude(W),               if y.f(x)>= 1
#      = lambda*magnitude(W) + 1 - f(x),    otherwise
# Where f(x) = y(Wx - b)
# The margin between the two classes = 2/magnitude(W) so W must be minimise in order
# to get the maximum margin.
# gradient descent is used to minimise it 
# update rule : w = w - learning rate * dw and b = b - learning rate * db

import numpy as np

class SVM:
    def __init__(self, learning_rate = 0.001, lambda_param = 0.01, n_iters=1000):
        self.lr = learning_rate
        self.lambda_param = lambda_param
        self.n_iters = n_iters
        self.w = None
        self.b = None
    
    def fit (self, X, y ):
        y_i = np.where(y <= 0, -1, 1)
        n_samples, n_features = X.shape
        self.w = np.zeros(n_features)
        self.b = 0

        # Gradient Descent
        for _ in range(self.n_iters):
            for idx, x_i in enumerate(X):
                condition = y_i[idx] * (np.dot(x_i, self.w) - self.b) >= 1
                if condition:
                    # derivative of loss function with respest to weight
                    self.w -= self.lr * (2*self.lambda_param*self.w) 
                else:
                    # derivative of loss function with respest to weight
                    self.w -= self.lr * (2*self.lambda_param*self.w - np.dot(x_i, y_i[idx]))
                    # derivative of loss function with respest to bias
                    self.b -= self.lr * y_i[idx]

    def predict(self, X):
        linear_output = np.dot(X, self.w) - self.b
        return np.sign(linear_output)


