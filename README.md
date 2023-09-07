# Sprawozdanie metodyki DevOps Ada Różańska
Niniejsze sprawozdanie przedstawia proces skonfigurowania procesu budowy, testowania i wdrożenia aplikacji opartej o konternery za pomocą oprogramowania Jenkins. Konfiguracja jest przechowywana w pliku `Jenkinsfile`. Definiowanie procesu budowy w repozytorium pozwala na zachowanie spójności i minimalizuje ryzyko problemów, gdy wiele osób używa tej samej instancji Jenkinsa 
### 1. Wykonanie forka repozytorium.
Kliknięcie przycisku Fork w serwisie GitHUb w repozytorium źródłowym spowoduje utworzenie forka.

![image](https://github.com/ada-roza/react-tetris/assets/123314121/f857dee2-0d98-438e-b0a2-9af0275caa25)

Następnie możemy pobrać sklonować repozytorium na komputer lokalny
```bash
git clone https://github.com/ada-roza/react-tetris.git
```
![image](https://github.com/ada-roza/react-tetris/assets/123314121/6a4a4d34-fe59-4ed0-ad5d-cdc8ec7fff00)

### 2. Dodanie Dockerfile
Aby skonteneryzować aplikację należy utworzyć plik `Dockerfile` i zdefiniować kroki budowy obrazu [OCI](https://opencontainers.org/). Użycie `yarn` zamiast `npm` nieco przyśpiesza instalację zależności.
```Dockerfile
FROM node
COPY package*.json .
RUN yarn
COPY . .
EXPOSE 8080
CMD ["yarn","start"]
```

### 3. Dodanie Jenkinsfile
Proces Jenkinsa dla tego projektu ma trzy fazy: `Build`, `Test` i `Deploy`. W fazie `Test` kolekcjonowane są wyniki testów z pliku `tests_coverage.txt`

```groovy
pipeline {
  agent any
  stages {
    stage('Build') {
      steps {
        sh 'yarn'
        sh 'yarn build'
      }
      post {
        success {
          echo 'Build is successful'
        }
        failure {
          echo 'Build errored'
        }
      }
    }
    stage('Test') {
      steps {
        sh 'yarn test'
      }
      post {
        success {
          echo 'Tests: passing'
          archiveArtifacts artifacts: 'tests_coverage.txt', followSymlinks: false
        }
        failure {
          echo 'Tests: failing'
        }
      }
    }
  }
}
```
