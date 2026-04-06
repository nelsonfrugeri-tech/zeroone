# Busca no PyPI e npm

## PyPI
```
# Search: https://pypi.org/search/?q=<query>
# Check package: https://pypi.org/project/<name>/
# Version history: https://pypi.org/project/<name>/#history
# Download stats: https://pypistats.org/packages/<name>
```

### Sinais Chave
- Data da última release (manutenção ativa?)
- Contagem de downloads (adoção)
- Suporte a versões Python
- Licença
- Contagem de dependências

## npm
```
# Search: https://www.npmjs.com/search?q=<query>
# Check package: https://www.npmjs.com/package/<name>
# Bundle size: https://bundlephobia.com/package/<name>
```

### Sinais Chave
- Downloads semanais
- Data da última publicação
- Bundle size (bundlephobia)
- TypeScript types (built-in vs @types)
- Tamanho descompactado

## Descoberta de Alternativas
- PyPI: `pip install <name>` → verifique se alternativas são listadas no README
- npm: busque por `<category>` no npm, ordene por popularidade
- Listas awesome-* no GitHub
