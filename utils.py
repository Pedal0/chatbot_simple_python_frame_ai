import os
import shutil
import logging

def clean_graphs_directory():
    """
    Supprime tous les fichiers du dossier 'graphs'.
    Crée le dossier s'il n'existe pas.
    """
    graphs_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "graphs")
    
    try:
        # Crée le dossier s'il n'existe pas
        if not os.path.exists(graphs_dir):
            os.makedirs(graphs_dir)
            logging.info(f"Dossier 'graphs' créé: {graphs_dir}")
            return True
        
        # Supprime tous les fichiers du dossier
        for item in os.listdir(graphs_dir):
            item_path = os.path.join(graphs_dir, item)
            try:
                if os.path.isfile(item_path):
                    os.unlink(item_path)
                elif os.path.isdir(item_path):
                    shutil.rmtree(item_path)
            except Exception as e:
                logging.error(f"Erreur lors de la suppression de {item_path}: {e}")
        
        logging.info(f"Dossier 'graphs' nettoyé avec succès")
        return True
    
    except Exception as e:
        logging.error(f"Erreur lors du nettoyage du dossier 'graphs': {e}")
        return False