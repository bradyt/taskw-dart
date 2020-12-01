Map parseTaskrc(String contents) => {
      for (var pair in contents
          .split('\n')
          .where((line) => line.contains('=') && line[0] != '#')
          .map((line) => line.replaceAll('\\/', '/'))
          .map((line) => line.split('=')))
        pair[0]: pair[1],
    };
