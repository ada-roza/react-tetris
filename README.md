# Sprawozdanie metodyki DevOps Adrianna Różańska
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
    stage('Deploy') {
      steps {
        sh 'docker-compose up -d'
      }
      post {
        success {
          echo 'Deployed!'
        }
        failure {
          echo 'Deployment failed'
        }
      }
    }
  }
}
```

### 4. Dodanie projektu do instancji Jenkinsa
W głównym widoku Jenkinsa klikamy `Nowy projekt`

![image](https://github.com/ada-roza/react-tetris/assets/123314121/c9a14d76-61e6-4bf6-bfaf-dc92bd2839c1)

Jako typ wybieramy `Pipeline`

![image](https://github.com/ada-roza/react-tetris/assets/123314121/df8d0229-c329-4608-a3a6-67e6993b00b6)

W sekcji Pipeline ustawiamy by definicja procesu była zaciągania z SCM. Podajemy adres repozytorium.

![image](https://github.com/ada-roza/react-tetris/assets/123314121/c149b898-1b32-4efb-add2-b576f71f530b)

Możemy też skonfigurować zadanie CRON, które będzie automatycznie wywoływać proces budowy. Jest to dobra praktyka, ponieważ serwer CI (ciągłej integracji) ma w założeniach zagwarantować jak największą spójność projektu w zespole. W firmach częstym wyborem jest budowa aplikacji co każdy commit lub każdej nocy o danej porze. My integrację będziemy przeprowadzać co 15 min.
```
H/15 * * * *
```

![image](https://github.com/ada-roza/react-tetris/assets/123314121/b6e5a2ab-1032-41b7-92f5-335247ae256f)


Teraz możemy kliknąć "Uruchom" aby wystartować proces budowy

![image](https://github.com/ada-roza/react-tetris/assets/123314121/80013cd3-3d4b-4711-805d-84c0913c4584)


Jak widać budowa przechodzi i mamy dostępny raport testowania projektu:

![image](https://github.com/ada-roza/react-tetris/assets/123314121/e9dd1ec2-8402-43ac-b3ea-f5cc6c9457db)

![image](https://github.com/ada-roza/react-tetris/assets/123314121/f0cbad03-2fcc-4a69-a128-6516dc91cbb9)

## Wymagania
- pipeline jest zdefniowany w Jenkinsfile w repo z grą - https://github.com/ada-roza/react-tetris/blob/master/Jenkinsfile
- pipeline jest automatycznie wyzwalany - jest, za pomocą CRON co 15 minut
- pipeline przechodzi wszystkie etapy (stage build-test-deploy) - tak, na zrzucie ekranu widać zielone statusy faz budowy
- pipeline obsługuje powiadamianie o rezlutatach każdego z etapów - tak, za pomocą sekcji `post` w Jenkinsfile



## Diagramy

Diagram aktywności procesu budowy:

![image](https://github.com/ada-roza/react-tetris/assets/123314121/cb8681cb-350e-4f11-b9d0-78126adf77e2)

| Nazwa kroku | Technologia | Plik | Linia | Komentarz |
|-------------|-------------|--------------------------------|----------|-----------|
| fetch       | git         | Jenkinsfile                    | -        | pobranie kodu źródłowego z Githuba |
| yarn build  | nodejs      | Jenkinsfile                    | 7        | uruchomienie procesu budowania projektu Nodejs |
| yarn test   | nodejs      | Jenkinsfile oraz package.json  | 20       | uruchomienie testów jednostkowych |
| archive     | jenkins     | Jenkinsfile                    | 25       | zachowanie pliku wynikowego z testów | 
| deploy | docker-compose | Jenkinsfile oraz docker-compose.yml | 34 | postawienie stosu aplikacyjnego docker-compose |
| echo | jenkins | Jenkinsfile | 38 | wypisanie komunikatu | 

Diagram wdrożeniowy (infrastruktura):

![image](https://github.com/ada-roza/react-tetris/assets/123314121/eeaa95dc-7034-44d5-b8e5-9293b016136a)

| Nazwa artefaktu | Technologia | Plik | Linia | Komentarz |
|-----------------|-------------|------|-------|-----------|
| jenkins         | java        | Jenkinsfile | wszystkie | instancja Jenkinsa i proces budowy w środku |
| repo            | github (ruby) | - | - | źródło kodu |
| silnik dockera  | docker      | - | - | środowisko wykonawczne kontenerów |
| kontener dockera | docker | Dockerfile | wszystkie |  definicja obrazu OCI |

