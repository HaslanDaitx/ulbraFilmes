import 'package:flutter/material.dart';
import '../../shared/theme/colors.dart';
import '../entity/filme_entity.dart';
import '../pages/detalhe_filme_page.dart';

class FilmeCard extends StatelessWidget {
  final FilmeEntity filme;

  const FilmeCard({super.key, required this.filme});

  bool get possuiPoster => filme.posterUrl.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          FocusScope.of(context).unfocus();

          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetalheFilmePage(id: filme.id.toString()),
            ),
          );

          Future.delayed(const Duration(milliseconds: 100), () {
            if (context.mounted) {
              FocusScope.of(context).unfocus();
            }
          });
        },
        child: Column(
          children: [
            Expanded(
              flex: 5,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                color: AppColors.branco.withValues(alpha: 0.45),
                child: possuiPoster
                    ? Image.network(
                        filme.posterUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.movie, size: 48);
                        },
                      )
                    : const Icon(Icons.movie, size: 48),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      textAlign: TextAlign.center,
                      filme.titulo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textoPrincipal,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        height: 1.15,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.calendar_month, size: 13),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            filme.ano,
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(
                          Icons.star,
                          size: 13,
                          color: AppColors.dourado,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          filme.notaFormatada,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      children: [
                        Text(
                          'Ver detalhes',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textoPrincipal,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 10,
                          color: AppColors.textoPrincipal,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
