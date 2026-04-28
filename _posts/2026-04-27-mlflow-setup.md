---
title: "MLflow Setup & MLOps"
date: 2026-04-27 20:48:55 -0400
categories: [ML-IA, MLOps]
tags: [MLflow, MLOps, ML-IA, Python]
image:
  path: https://i.pinimg.com/originals/5a/a8/69/5aa869da340cbf31e3570f19ea3452a6.gif
---

<div style="text-align: justify;" markdown="1">

# Introduction

This is a practical guide for setting up and using MLflow in a local machine
learning project.

MLflow is useful when you want to track experiments, compare runs, save models,
store metrics, and keep a better history of what happened during training. In
small projects, it helps you avoid losing context. In larger projects, it
becomes part of the MLOps workflow.

# What MLflow Helps With

When training models, it is easy to lose track of important details:

- which dataset version was used;
- which hyperparameters were tested;
- which metric improved or got worse;
- which model artifact belongs to which experiment;
- how to load an old model again.

MLflow gives you a way to log those details in a structured way.

# Basic Project Setup

I usually prefer starting with a clean Python environment. You can use Poetry or
a regular virtual environment.

## Option 1: Using Poetry

```console
$ poetry init
$ poetry add "mlflow==3.11.1" "pandas>=2.2,<3" scikit-learn
$ poetry add "graphene>=3,<4"
$ poetry add --group dev taskipy
$ poetry shell
```

I pinned `pandas` to `<3` because MLflow still expects pandas 2.x in this
setup. I also added `graphene>=3,<4` because the MLflow UI uses GraphQL, and an
older GraphQL stack can break the `/graphql` endpoint.

## Option 2: Using venv

```console
$ python -m venv .venv
$ source .venv/bin/activate
$ pip install mlflow scikit-learn pandas
```

After installing MLflow, check if it is available:

```console
$ mlflow --version
```
> `mlflow, version 3.11.1`

# Using Taskipy

Instead of typing long commands every time, I prefer creating tasks in
`pyproject.toml`.

```toml
[tool.taskipy.tasks]
mlflow = "mlflow server --host 127.0.0.1 --port 5000 --backend-store-uri sqlite:///mlflow.db --default-artifact-root ./mlartifacts"
mlflow-check = "python mlflow_server/server_testfile.py"
train = "python model/train.py"
```

Now the workflow is easier to remember.

Start the MLflow server:

```console
$ task mlflow
```

In another terminal, test the connection:

```console
$ task mlflow-check
```

Then run the training script:

```console
$ task train
```

# Starting the MLflow UI

For a quick local setup, start the MLflow tracking server:

```console
$ task mlflow
```

Or run the command manually:

```console
$ mlflow server --host 127.0.0.1 --port 5000 --backend-store-uri sqlite:///mlflow.db --default-artifact-root ./mlartifacts
```

Then open:

```text
http://127.0.0.1:5000
```

This gives you the MLflow UI, where you can inspect experiments, runs, metrics,
parameters, and artifacts.

# Testing the Connection

Before training a model, I like to test if the script can connect to the MLflow
server.

Create `mlflow_server/server.py`:

```python
import mlflow

TRACKING_URI = "http://127.0.0.1:5000"
EXPERIMENT_NAME = "my-first-experiment"


def configure_mlflow() -> None:
    mlflow.set_tracking_uri(TRACKING_URI)
    mlflow.set_experiment(EXPERIMENT_NAME)
```

Then create `mlflow_server/server_testfile.py`:

```python
import mlflow

from mlflow_server.server import EXPERIMENT_NAME, configure_mlflow


configure_mlflow()

print(f"MLflow Tracking URI: {mlflow.get_tracking_uri()}")
print(f"Active Experiment: {mlflow.get_experiment_by_name(EXPERIMENT_NAME)}")

with mlflow.start_run(run_name="connection-test"):
    mlflow.log_param("test_param", "test_value")
    print("Successfully connected to MLflow!")
```

Run:

```console
$ task mlflow-check
```

If everything is working, the test run should appear in the MLflow UI.

# Creating a First Experiment

Create a file called `train.py`:

```python
import mlflow
import mlflow.sklearn
from sklearn.datasets import load_iris
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score
from sklearn.model_selection import train_test_split


mlflow.set_tracking_uri("http://127.0.0.1:5000")
mlflow.set_experiment("mlflow-local-guide")

X, y = load_iris(return_X_y=True)

X_train, X_test, y_train, y_test = train_test_split(
    X,
    y,
    test_size=0.2,
    random_state=42,
)

params = {
    "solver": "lbfgs",
    "max_iter": 1000,
    "random_state": 42,
}

with mlflow.start_run():
    model = LogisticRegression(**params)
    model.fit(X_train, y_train)

    predictions = model.predict(X_test)
    accuracy = accuracy_score(y_test, predictions)

    mlflow.log_params(params)
    mlflow.log_metric("accuracy", accuracy)
    mlflow.sklearn.log_model(model, name="iris-logistic-regression")

    print(f"Accuracy: {accuracy:.4f}")
```

Run it:

```console
$ python train.py
```

After running the script, go back to the MLflow UI and open the
`mlflow-local-guide` experiment. You should see one run with parameters,
metrics, and a logged model artifact.

# Using Autologging

MLflow also supports autologging for some libraries. With scikit-learn, you can
enable it like this:

```python
import mlflow
import mlflow.sklearn

mlflow.sklearn.autolog()
```

Autologging is useful when you want MLflow to capture common parameters,
metrics, and model artifacts automatically. Manual logging is still useful when
you want more control over what gets stored.

# Loading a Logged Model

After logging a model, you can load it again using its model URI.

The easiest way is to copy the model URI from the MLflow UI and use:

```python
import mlflow

model_uri = "runs:/<run_id>/iris-logistic-regression"
model = mlflow.pyfunc.load_model(model_uri)
```

Then you can use the model for inference:

```python
predictions = model.predict(X_test)
```

# What Should Go Into Git?

For local experiments, MLflow may create folders and files such as:

- `mlruns/`
- `mlartifacts/`
- `mlflow.db`

In most cases, I do not want to commit those generated experiment artifacts to
Git. They are local outputs, not source code.

The code, configuration, and notes should go into Git. The experiment artifacts
should usually stay in MLflow storage.

# Troubleshooting

## GraphQL Import Error

While opening the MLflow UI, I hit this error:

```text
ImportError: cannot import name 'DocumentNode' from 'graphql.language.ast'
```

In my case, the environment had an old GraphQL stack:

```text
graphql-core 2.3.2
graphene 2.1.9
```

MLflow expected the newer GraphQL AST classes, so I fixed it by installing
Graphene 3:

```console
$ poetry add "graphene>=3,<4"
```

Then I checked if the right objects existed:

```console
$ poetry run python -c "import graphql, graphql.language.ast as ast; print(graphql.__version__); print(hasattr(ast, 'DocumentNode'))"
```

Expected result:

```text
3.2.8
True
```

After changing dependencies, restart the MLflow server. Python will not reload
already imported packages inside a running process.

# What's Next?

This local setup is enough for learning and small experiments. The next step is
to study a more production-like setup using:

- a backend store such as SQLite or PostgreSQL;
- artifact storage;
- model registry;
- Docker;
- CI/CD;
- deployment workflows.

For now, the most important habit is simple: every experiment should leave a
trace. Parameters, metrics, artifacts, and notes should be easy to inspect
later.

# References

- [MLflow Tracking Quickstart](https://mlflow.org/docs/latest/ml/getting-started/quickstart/)
- [MLflow Documentation](https://mlflow.org/docs/latest/)

</div>
