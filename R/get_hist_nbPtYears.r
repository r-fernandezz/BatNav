

get_hist_nbPtYears <- function(df_gpsRCT) {

    if("nom_individu" %in% colnames(df_gpsRCT)) {

            df_count <- aggregate(
                    x = list(nb_point = df_gpsRCT$nom_individu),
                    by = list(year = df_gpsRCT$Year, nom_individu = df_gpsRCT$nom_individu),
                    FUN = length
                )
            group_color <- "nom_individu"
            legend <- "Nom de l'individu"

        } else if (!"nom_individu" %in% colnames(df_gpsRCT)) {

            df_count <- aggregate(
                    x = list(nb_point = df_gpsRCT$DeviceID),
                    by = list(year = df_gpsRCT$Year, DeviceID = df_gpsRCT$DeviceID),
                    FUN = length
                )
            group_color <- "DeviceID"
            legend <- "Numéro de GPS"

        }

        ggplot(df_count, aes(x = as.factor(year), y = nb_point, fill = as.factor(!!sym(group_color)))) +
        geom_histogram(stat = "identity", position = "dodge") +
        scale_fill_manual(values = c(
                                    "#FF0000", "#FF9900", "#FFCC00", "#00FF00", "#6699FF", "#CC33FF", "#99991E",
                                    "#999999", "#FF00CC", "#CC0000", "#FFCCCC", "#FFFF00", "#CCFF00", "#358000",
                                    "#0000CC", "#99CCFF", "#00FFFF", "#CCFFFF", "#9900CC", "#CC99FF", "#996600",
                                    "#666600", "#666666", "#CCCCCC", "#79CC3D", "#CCCC99"
                                    )) +
        labs(x = "Années", y = "Nombre de points", fill = legend) +
        theme_minimal() +
        theme(
            title.text.y = element_text(face = "bold", size = 14),
            title.text.x = element_text(face = "bold", size = 14)
        )

}