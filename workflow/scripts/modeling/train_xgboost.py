#!/usr/bin/env python
# ---------------------------
# Trains an xgboost from the kmer count table
# Author: Paul Villanueva (github.com/pommevilla)
# ---------------------------

if __name__ == "__main__":
    import pandas as pd
    import numpy as np
    from xgboost import XGBClassifier
    from sklearn.model_selection import train_test_split
    from sklearn.metrics import accuracy_score
    from sklearn.model_selection import GridSearchCV
    from joblib import dump

    # Read in the kmer count table with just the first 100 columns for now
    kmer_counts = pd.read_csv("data/all_kmer_counts.csv", index_col=0)

    kmer_counts = kmer_counts.iloc[:, :100]

    # Adding a random column to serve as a prediction target
    kmer_counts["target"] = np.random.randint(0, 2, size=len(kmer_counts))

    # Create train-test split
    X_train, X_test, y_train, y_test = train_test_split(
        kmer_counts.iloc[:, :-1], kmer_counts["target"], test_size=0.2, random_state=489
    )

    # Hyperparameter grid
    param_grid = {
        "max_depth": [3, 7],
        "learning_rate": [1, 0.01],
        "subsample": [0.5, 1],
    }

    bst = XGBClassifier()

    gridsearch = GridSearchCV(
        bst,
        param_grid,
        cv=3,
        scoring="accuracy",
    )

    # This is data leakage, but will fix this when we use the full dataset
    # Also, since this is being performed on such a small subset, the cv split
    # will sometimes not work since there won't be enough class members to split nicely.
    # Again, this is something that will be fixed with the full dataset. For now, just run
    # it a few times until it goes through.
    # Note - a depecration warning shows up here from XGBoost. This will be fixed
    # in a future version
    gridsearch.fit(X_train, y_train)

    # Save gridsearch object

    dump(gridsearch, "results/modeling/xgboost_gridsearch.pkl")

    print(gridsearch.best_params_)

    preds = gridsearch.predict(X_test)

    print(f"Accuracy: {accuracy_score(y_test, preds)}")
