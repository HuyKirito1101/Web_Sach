package vn.iotstar.websach.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import vn.iotstar.websach.entity.Author;

@Repository
public interface AuthorRepository extends JpaRepository<Author, Long> {
}
