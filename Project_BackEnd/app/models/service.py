from decimal import Decimal

from sqlalchemy import CheckConstraint, Integer, Numeric, String, Text
from sqlalchemy.orm import Mapped, mapped_column

from app.infra.database import Base


class Service(Base):
    __tablename__ = "services"

    __table_args__ = (
        CheckConstraint("price > 0", name="ck_services_price_positive"),
        CheckConstraint("duration_minutes > 0", name="ck_services_duration_positive"),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    name: Mapped[str] = mapped_column(String(100), nullable=False, unique=True, index=True)
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    price: Mapped[Decimal] = mapped_column(
        Numeric(precision=10, scale=2),
        nullable=False,
    )
    duration_minutes: Mapped[int] = mapped_column(
        Integer,
        nullable=False,
        comment="Duração do serviço em minutos. Ex: 120 = 2 horas.",
    )

    def __repr__(self) -> str:
        return (
            f"<Service id={self.id} name={self.name!r} "
            f"price={self.price} duration={self.duration_minutes}min>"
        )