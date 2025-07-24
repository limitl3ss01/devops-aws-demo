# DevOps AWS Demo

Projekt demonstracyjny DevOps: automatyczny deployment aplikacji Python (Flask) w chmurze AWS z CI/CD, Infrastructure as Code (Terraform) oraz monitoringiem (Prometheus + Grafana).

---

## Spis treści
- [Opis projektu](#opis-projektu)
- [Architektura](#architektura)
- [Stack technologiczny](#stack-technologiczny)
- [Plan działania](#plan-działania)
- [Instrukcja uruchomienia](#instrukcja-uruchomienia)
- [Diagramy](#diagramy)
- [Autor](#autor)

---

## Opis projektu
Celem projektu jest pokazanie pełnego procesu DevOps: od kodu aplikacji, przez automatyzację testów i deploymentu, po monitoring w środowisku chmurowym AWS. Wszystko w duchu Infrastructure as Code.

## Architektura
- Aplikacja Python (Flask) uruchamiana w kontenerze Docker
- CI/CD: GitHub Actions
- Infrastruktura: AWS (EC2, S3, VPC) zarządzana przez Terraform
- Monitoring: Prometheus + Grafana

## Stack technologiczny
- Python 3.x, Flask
- Docker
- GitHub Actions
- Terraform
- AWS (EC2, S3, IAM, VPC)
- Prometheus, Grafana

## Plan działania
1. Prosta aplikacja Flask
2. Dockerfile i docker-compose
3. Pipeline CI (testy, build obrazu)
4. Pipeline CD (deployment na AWS)
5. Infrastructure as Code (Terraform)
6. Monitoring (Prometheus, Grafana)
7. Dokumentacja i diagramy

## Instrukcja uruchomienia
Szczegółowe instrukcje pojawią się w kolejnych commitach wraz z rozwojem projektu.

## Diagramy
(Tu wstaw diagramy architektury, np. wygenerowane w draw.io lub Mermaid)

## Autor
Imię Nazwisko (Twój nick z GitHub) 